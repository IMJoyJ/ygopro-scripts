--メメント・カクタス
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。这个回合中，9星以上的「莫忘」怪兽可以直接攻击。
-- ②：这张卡被效果破坏的场合，以这张卡以外的自己的墓地·除外状态的1张「莫忘」卡为对象才能发动。那张卡加入手卡。
-- ③：这张卡在墓地存在的状态，自己的手卡·场上（表侧表示）的「莫忘」怪兽被战斗·效果破坏的场合才能发动。这张卡特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。这个回合中，9星以上的「莫忘」怪兽可以直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"直接攻击"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	-- 设置发动条件：只能在可以进行战斗操作的时点或阶段发动
	e1:SetCondition(aux.bpcon)
	e1:SetTarget(s.datg)
	e1:SetOperation(s.daop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡被效果破坏的场合，以这张卡以外的自己的墓地·除外状态的1张「莫忘」卡为对象才能发动。那张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"回到手卡"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	-- ③：这张卡在墓地存在的状态，自己的手卡·场上（表侧表示）的「莫忘」怪兽被战斗·效果破坏的场合才能发动。这张卡特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,id+o*2)
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
-- 直接攻击效果的发动检测
function s.datg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合是否尚未适用过该直接攻击效果的全局标记
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
end
-- 直接攻击效果的执行：注册一个使特定怪兽可以直接攻击的全局效果，并注册已适用的全局标记
function s.daop(e,tp,eg,ep,ev,re,r,rp)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。这个回合中，9星以上的「莫忘」怪兽可以直接攻击。②：这张卡被效果破坏的场合，以这张卡以外的自己的墓地·除外状态的1张「莫忘」卡为对象才能发动。那张卡加入手卡。③：这张卡在墓地存在的状态，自己的手卡·场上（表侧表示）的「莫忘」怪兽被战斗·效果破坏的场合才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(s.dafilter)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 在全局环境中注册该直接攻击效果
	Duel.RegisterEffect(e1,tp)
	-- 为玩家注册本回合已适用该效果的全局标记，持续到回合结束
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
-- 过滤条件：9星以上的「莫忘」怪兽
function s.dafilter(e,c)
	return c:IsSetCard(0x1a1) and c:IsLevelAbove(9)
end
-- 发动条件：被效果破坏
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0
end
-- 过滤条件：这张卡以外的自己墓地或除外状态的「莫忘」卡，且可以加入手卡（除外状态的卡必须表侧表示）
function s.thfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x1a1) and c:IsAbleToHand()
end
-- 回收效果的对象选择与操作信息设置
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.thfilter(chkc) and chkc~=e:GetHandler() end
	-- 检查是否存在可以加入手卡的符合条件的目标卡
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,e:GetHandler()) end
	-- 向玩家发送提示信息：选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择并确认1张符合条件的目标卡
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,e:GetHandler())
	-- 设置操作信息：将选中的卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 回收效果的执行：将目标卡加入手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时的目标卡
	local tc=Duel.GetFirstTarget()
	-- 检查目标卡是否仍符合效果关系，且不受「王家之谷」影响
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
		-- 将目标卡加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 过滤条件：原本由自己控制的、被战斗或效果破坏的、手卡或场上表侧表示的「莫忘」怪兽
function s.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsType(TYPE_MONSTER) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and (c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousSetCard(0x1a1)
			or c:IsPreviousLocation(LOCATION_HAND) and c:IsSetCard(0x1a1))
end
-- 发动条件：自己手卡·场上的「莫忘」怪兽被破坏，且被破坏的卡不包含墓地中的这张卡自身
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 特殊召唤效果的发动检测与操作信息设置
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域，且这张卡是否可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：将这张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的执行：将这张卡特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
