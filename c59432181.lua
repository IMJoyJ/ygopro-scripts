--融合識別
-- 效果：
-- ①：以自己场上1只怪兽为对象才能发动。把额外卡组1只融合怪兽给对方观看。这个回合，把作为对象的怪兽作为融合素材的场合，可以作为那只给人观看的怪兽的同名卡来成为融合素材。
function c59432181.initial_effect(c)
	-- ①：以自己场上1只怪兽为对象才能发动。把额外卡组1只融合怪兽给对方观看。这个回合，把作为对象的怪兽作为融合素材的场合，可以作为那只给人观看的怪兽的同名卡来成为融合素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c59432181.target)
	e1:SetOperation(c59432181.activate)
	c:RegisterEffect(e1)
end
-- 定义作为效果对象的怪兽的过滤条件
function c59432181.filter(c,tp)
	-- 检查卡片是否在场上表侧表示，且额外卡组存在可展示的融合怪兽
	return c:IsFaceup() and Duel.IsExistingMatchingCard(c59432181.cfilter,tp,LOCATION_EXTRA,0,1,nil,c)
end
-- 定义额外卡组中用于展示的融合怪兽的过滤条件
function c59432181.cfilter(c,tc)
	return c:IsType(TYPE_FUSION) and not c:IsCode(tc:GetFusionCode())
end
-- 定义效果发动时的目标选择与合法性检查
function c59432181.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c59432181.filter(chkc,tp) end
	-- 在发动准备阶段，检查自己场上是否存在至少1只满足条件的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c59432181.filter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择作为效果对象的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,c59432181.filter,tp,LOCATION_MZONE,0,1,1,nil,tp)
end
-- 定义效果处理的执行逻辑
function c59432181.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	-- 提示玩家选择要给对方确认的额外卡组卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从额外卡组选择1只满足条件的融合怪兽
	local cg=Duel.SelectMatchingCard(tp,c59432181.cfilter,tp,LOCATION_EXTRA,0,1,1,nil,tc)
	if cg:GetCount()==0 then return end
	-- 将选中的融合怪兽给对方玩家确认
	Duel.ConfirmCards(1-tp,cg)
	local code1,code2=cg:GetFirst():GetOriginalCodeRule()
	-- 这个回合，把作为对象的怪兽作为融合素材的场合，可以作为那只给人观看的怪兽的同名卡来成为融合素材。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(59432181,0))  --"「融合识别」效果适用中"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ADD_FUSION_CODE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(code1)
	tc:RegisterEffect(e1)
	if code2 then
		local e2=e1:Clone()
		e2:SetValue(code2)
		tc:RegisterEffect(e2)
	end
end
