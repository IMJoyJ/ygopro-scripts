--Genia of the Ring
-- 效果：
-- 这张卡在手卡存在的场合：可以以场上1只表侧表示怪兽为对象；这张卡特殊召唤，作为对象的怪兽变成魔法师族。这个回合，作为对象的怪兽只有1次不会被卡的效果破坏，这个效果的发动后，直到回合结束时自己不是魔法师族怪兽不能从额外卡组特殊召唤。
-- 这张卡为让魔法师族怪兽的效果发动而被解放或者被除外的场合：可以把这张卡加入手卡。
-- 「戒指的魔灵」的每个效果1回合各能使用1次。
local s,id,o=GetID()
-- 注册卡片效果的函数
function s.initial_effect(c)
	-- 这张卡在手卡存在的场合：可以以场上1只表侧表示怪兽为对象；这张卡特殊召唤，作为对象的怪兽变成魔法师族。这个回合，作为对象的怪兽只有1次不会被卡的效果破坏，这个效果的发动后，直到回合结束时自己不是魔法师族怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 这张卡为让魔法师族怪兽的效果发动而被解放或者被除外的场合：可以把这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回到手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_RELEASE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e3)
end
-- 过滤函数：场上的表侧表示怪兽
function s.spfilter(c)
	return c:IsFaceup()
end
-- 特殊召唤并改变种族效果的发动准备与合法性检测函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.spfilter(chkc) end
	local c=e:GetHandler()
	-- 检测场上是否存在可以作为对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(s.spfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 且自己场上有空余的怪兽区域，并且这张卡可以特殊召唤
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 给玩家提示：选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上1只表侧表示怪兽作为效果的对象
	Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息：包含特殊召唤这张卡的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 特殊召唤并改变种族效果的效果处理函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断这张卡是否仍与连锁相关并尝试正面表侧表示特殊召唤
	local res=c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0
	if res and tc:IsRelateToChain() and tc:IsFaceup() and tc:IsLocation(LOCATION_MZONE) and not tc:IsImmuneToEffect(e) then
		-- 作为对象的怪兽变成魔法师族
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetValue(RACE_SPELLCASTER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
	-- 这个回合，作为对象的怪兽只有1次不会被卡的效果破坏
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCountLimit(1)
	e2:SetValue(s.valcon)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e2)
	-- 这个效果的发动后，直到回合结束时自己不是魔法师族怪兽不能从额外卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetReset(RESET_PHASE+PHASE_END)
	e3:SetTarget(s.splimit)
	-- 向玩家注册直到回合结束前自己不能特殊召唤魔法师族以外的额外卡组怪兽的效果
	Duel.RegisterEffect(e3,tp)
end
-- 抗性适用条件判定函数：仅卡的效果破坏
function s.valcon(e,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0
end
-- 限制特殊召唤额外卡组非魔法师族怪兽的过滤函数
function s.splimit(e,c)
	return not c:IsRace(RACE_SPELLCASTER) and c:IsLocation(LOCATION_EXTRA)
end
-- 回到手卡效果的发动条件判定函数
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_COST) and re:IsActivated() and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsRace(RACE_SPELLCASTER)
end
-- 回到手卡效果的发动准备与合法性检测函数
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置连锁操作信息：包含将这张卡加入手卡的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 回到手卡效果的效果处理函数
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断这张卡是否仍与连锁相关且不受王家长眠之谷的影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将这张卡加入手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
