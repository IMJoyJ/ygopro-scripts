--無限起動ゴライアス
-- 效果：
-- 连接怪兽以外的「无限起动」怪兽1只
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡从场上送去墓地的场合，以自己场上1只超量怪兽为对象才能发动。把这张卡在那只怪兽下面重叠作为超量素材。
-- ②：持有这张卡作为素材中的原本种族是机械族的超量怪兽得到以下效果。
-- ●这张卡不会被效果破坏。
function c23689428.initial_effect(c)
	-- 为这张卡添加连接召唤手续：用1只满足条件的怪兽作素材（连接怪兽以外的「无限起动」怪兽）
	aux.AddLinkProcedure(c,c23689428.matfilter,1,1)
	c:EnableReviveLimit()
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡从场上送去墓地的场合，以自己场上1只超量怪兽为对象才能发动。把这张卡在那只怪兽下面重叠作为超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23689428,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,23689428)
	e1:SetCondition(c23689428.xyzcon)
	e1:SetTarget(c23689428.xyztg)
	e1:SetOperation(c23689428.xyzop)
	c:RegisterEffect(e1)
	-- ②：持有这张卡作为素材中的原本种族是机械族的超量怪兽得到以下效果。●这张卡不会被效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_XMATERIAL)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetCondition(c23689428.condition)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- 判定连接素材：素材必须是「无限起动」系列怪兽，且不是连接怪兽。
function c23689428.matfilter(c)
	return c:IsLinkSetCard(0x127) and not c:IsLinkType(TYPE_LINK)
end
-- ①效果的发动条件：这张卡是从场上被送去墓地（此前所在区域为场上）。
function c23689428.xyzcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 选择对象时的过滤条件：表侧表示的超量怪兽。
function c23689428.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- ①效果的发动时点与取对象处理：检查是否存在合法目标（自己场上的表侧表示超量怪兽），且这张卡自身可以作为超量素材。
function c23689428.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c23689428.filter(chkc) end
	-- 效果发动时确认：自己场上存在至少1只可选择的表侧表示超量怪兽，且这张卡可以作为超量素材。
	if chk==0 then return Duel.IsExistingTarget(c23689428.filter,tp,LOCATION_MZONE,0,1,nil)
		and e:GetHandler():IsCanOverlay() end
	-- 向操作玩家发出选择对象的提示消息，文字为“请选择效果的对象”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让操作玩家从自己场上选择1只表侧表示超量怪兽作为效果的对象，并记录为连锁对象。
	Duel.SelectTarget(tp,c23689428.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：这张卡将涉及从墓地离开（作为超量素材叠放），供「王家长眠之谷」等卡检测。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- ①效果处理：若目标怪兽仍与效果关联且不免疫此效果，自身也仍与效果关联且可作为超量素材，则将这张卡叠放到目标超量怪兽下方作为超量素材。
function c23689428.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果处理时选择的对象卡（那只超量怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) and c:IsRelateToEffect(e) and c:IsCanOverlay() then
		-- 将这张卡作为超量素材，叠放到目标超量怪兽下方。
		Duel.Overlay(tc,Group.FromCards(c))
	end
end
-- ②效果的适用条件：持有这张卡作为素材的超量怪兽的原本种族是机械族。
function c23689428.condition(e)
	return e:GetHandler():GetOriginalRace()==RACE_MACHINE
end
