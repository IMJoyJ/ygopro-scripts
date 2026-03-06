--暗黒界の混沌王 カラレス
-- 效果：
-- 「暗黑界的魔神 雷恩」＋恶魔族怪兽2只以上
-- ①：这张卡融合召唤的场合才能发动。对方场上的卡全部破坏。
-- ②：这张卡的原本的攻击力·守备力变成作为这张卡的融合素材的怪兽数量×1000。
-- ③：自己·对方回合1次，以自己场上1张表侧表示卡为对象才能发动。选自己1张手卡丢弃。这个回合，对方不能把作为对象的表侧表示卡作为效果的对象。
local s,id,o=GetID()
-- 初始化卡片效果，启用融合召唤限制，设置融合召唤条件为必须使用「暗黑界的魔神 雷恩」和至少2只恶魔族怪兽作为融合素材
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤条件为必须使用卡号为99458769的怪兽和至少2只恶魔族怪兽作为融合素材
	aux.AddFusionProcCodeFunRep(c,99458769,aux.FilterBoolFunction(Card.IsRace,RACE_FIEND),2,127,true,true)
	-- ①：这张卡融合召唤的场合才能发动。对方场上的卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"对方场上的卡全部破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.sumcon)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	-- ②：这张卡的原本的攻击力·守备力变成作为这张卡的融合素材的怪兽数量×1000。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.sumcon)
	e2:SetOperation(s.sucop)
	c:RegisterEffect(e2)
	-- ③：自己·对方回合1次，以自己场上1张表侧表示卡为对象才能发动。选自己1张手卡丢弃。这个回合，对方不能把作为对象的表侧表示卡作为效果的对象。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"选自己1张手卡丢弃"
	e3:SetCategory(CATEGORY_HANDES)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
-- 判断是否为融合召唤
function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 设置效果目标为对方场上的所有卡
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1张卡
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上的所有卡
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 设置连锁操作信息为破坏效果
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 执行破坏效果，将对方场上的所有卡破坏
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的所有卡
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 将对方场上的所有卡破坏
	Duel.Destroy(sg,REASON_EFFECT)
end
-- 融合召唤成功后，设置攻击力和守备力为融合素材数量乘以1000
function s.sucop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 设置攻击力为融合素材数量乘以1000
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetValue(c:GetMaterialCount()*1000)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_BASE_DEFENSE)
	c:RegisterEffect(e2)
end
-- 设置效果目标为己方场上的1张表侧表示卡
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 检查己方场上是否存在至少1张表侧表示卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,0,1,nil)
		-- 检查己方手牌数量是否大于0
		and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 end
	-- 提示玩家选择一张表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择一张己方场上的表侧表示卡作为效果目标
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 设置连锁操作信息为丢弃手牌效果
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
-- 执行效果操作，丢弃1张手牌并使目标卡不能成为效果对象
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果目标卡
	local tc=Duel.GetFirstTarget()
	-- 丢弃1张手牌
	if Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)~=0
		and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 使目标卡在本回合不能成为效果对象
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,2))  --"「暗黑界的混沌王 卡勒莱斯」效果适用中"
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetValue(s.tgoval)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 返回对方玩家的玩家编号
function s.tgoval(e,re,rp)
	return rp==1-e:GetOwnerPlayer()
end
