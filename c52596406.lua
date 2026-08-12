--白曼波
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡在手卡存在的场合，以同名卡在自己场上存在的自己墓地1只4星以下的鱼族怪兽为对象才能发动。这张卡特殊召唤，作为对象的怪兽特殊召唤。
-- ②：这张卡从墓地特殊召唤的场合才能发动。这个回合，这张卡当作调整使用。
local s,id,o=GetID()
-- 初始化卡片效果：注册效果①（手卡发动的起动效果，取自己墓地1只4星以下且同名卡在自己场上存在的鱼族怪兽为对象，1回合1次，把这张卡和对象怪兽特殊召唤）和效果②（这张卡从墓地特殊召唤成功时的诱发选发效果，这个回合当作调整使用）
function s.initial_effect(c)
	-- ①：这张卡在手卡存在的场合，以同名卡在自己场上存在的自己墓地1只4星以下的鱼族怪兽为对象才能发动。这张卡特殊召唤，作为对象的怪兽特殊召唤。这个卡名的①的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡从墓地特殊召唤的场合才能发动。这个回合，这张卡当作调整使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(s.tncon)
	e2:SetOperation(s.tnop)
	c:RegisterEffect(e2)
end
s.treat_itself_tuner=true
-- 过滤函数：判断卡片是否表侧表示存在且卡名（卡号）为指定的卡，用于检测同名卡是否在自己场上存在
function s.cfilter(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
-- 过滤函数：判断卡片是否为4星以下的鱼族怪兽、自己场上存在与其同名的卡、且可以被特殊召唤，用于筛选可以作为效果对象的墓地怪兽
function s.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_FISH)
		-- 检测自己场上是否存在与该卡同名的卡（对应效果条件中的「同名卡在自己场上存在」）
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil,c:GetCode())
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的对象处理：若正在选择对象则校验所选卡是否为自己墓地满足条件的怪兽；发动条件检测：未受「青眼精灵龙」影响、自己怪兽区有2个以上可用空格、这张卡可以特殊召唤、且自己墓地存在可作为对象的满足条件的怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	local c=e:GetHandler()
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 确认自己主要怪兽区有2个以上可用空格（需要同时特殊召唤2只怪兽），且这张卡本身可以被特殊召唤
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 确认自己墓地存在1只以上满足条件且能成为效果对象的怪兽
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家发送选择提示：「请选择要特殊召唤的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只满足条件的怪兽作为效果对象，并与这张卡（自身）一起组成要特殊召唤的卡组
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)+c
	-- 设置连锁的操作信息：分类为特殊召唤，确定要处理的卡为对象怪兽和这张卡共2张
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,0,0)
end
-- 效果①的处理：取得效果对象；若这张卡与效果仍有关联，则先将这张卡以表侧表示特殊召唤，若成功后怪兽区仍有空格、对象怪兽仍与效果关联且未受「青眼精灵龙」影响，则再将对象怪兽特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 取得当前连锁的第1个效果对象（即被选中的墓地鱼族怪兽）
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) then return end
	-- 先将这张卡以表侧表示特殊召唤（分步处理），并确认特殊召唤成功后怪兽区仍有可用空格
	if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and tc:IsRelateToEffect(e) and not Duel.IsPlayerAffectedByEffect(tp,59822133) then
		-- 将作为对象的怪兽以表侧表示特殊召唤（分步处理）
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 结束分步特殊召唤处理，完成本次特殊召唤
	Duel.SpecialSummonComplete()
end
-- 效果②的发动条件：这张卡的特殊召唤之前的位置是墓地（即从墓地特殊召唤的场合）
function s.tncon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE)
end
-- 效果②的处理：若这张卡与效果仍有关联，则给这张卡注册一个不会被无效的永续效果：这个回合增加「调整」种类（当作调整使用），回合结束时重置
function s.tnop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- ②：这个回合，这张卡当作调整使用。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetValue(TYPE_TUNER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
