--空隙の原星竜
-- 效果：
-- 光·暗属性的龙族怪兽＋龙族怪兽
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡融合召唤的场合，以最多有那些作为融合素材的自己的光·暗属性怪兽数量的对方场上的卡为对象才能发动。那些卡破坏。
-- ②：这张卡被除外的场合，以自己场上1只光·暗属性的龙族·4星怪兽为对象才能发动。那只怪兽的等级变成8星。
local s,id,o=GetID()
-- 注册卡片的效果与融合召唤手续
function s.initial_effect(c)
	-- 添加融合召唤手续：光·暗属性的龙族怪兽＋龙族怪兽
	aux.AddFusionProcFun2(c,s.mfilter1,s.mfilter2,true)
	c:EnableReviveLimit()
	-- ①：这张卡融合召唤的场合，以最多有那些作为融合素材的自己的光·暗属性怪兽数量的对方场上的卡为对象才能发动。那些卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.descon)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	-- ②：这张卡被除外的场合，以自己场上1只光·暗属性的龙族·4星怪兽为对象才能发动。那只怪兽的等级变成8星。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.lvtg)
	e2:SetOperation(s.lvop)
	c:RegisterEffect(e2)
end
-- 过滤融合素材1：光·暗属性的龙族怪兽
function s.mfilter1(c)
	return c:IsFusionAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsRace(RACE_DRAGON)
end
-- 过滤融合素材2：龙族怪兽
function s.mfilter2(c)
	return c:IsRace(RACE_DRAGON)
end
-- 判断是否为融合召唤成功
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 过滤作为融合素材的、原本控制者为自己的光·暗属性怪兽
function s.desfilter(c,tp)
	return c:IsAttribute(ATTRIBUTE_DARK+ATTRIBUTE_LIGHT) and c:GetPreviousControler()==tp
end
-- 效果①的靶向选择与发动准备
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	local ct=e:GetHandler():GetMaterial():FilterCount(s.desfilter,nil,tp)
	-- 检查是否存在至少1个符合条件的融合素材，且对方场上存在可作为对象的卡
	if chk==0 then return ct>0 and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择最多等同于符合条件素材数量的对方场上的卡作为对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,ct,nil)
	-- 设置效果处理信息：破坏选中的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果①的处理：破坏作为对象的卡
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取仍与效果相关的对象卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 因效果破坏这些卡
	Duel.Destroy(g,REASON_EFFECT)
end
-- 过滤自己场上表侧表示的光·暗属性龙族4星怪兽
function s.lvfilter(c)
	return c:IsFaceup() and c:IsLevel(4)
		and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsRace(RACE_DRAGON)
end
-- 效果②的靶向选择与发动准备
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.lvfilter(chkc) end
	-- 检查自己场上是否存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择1只符合条件的怪兽作为对象
	Duel.SelectTarget(tp,s.lvfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果②的处理：将作为对象的怪兽等级变成8星
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取第一个对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsLevel(8) then
		-- 那只怪兽的等级变成8星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(8)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
