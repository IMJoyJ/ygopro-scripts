--無限起動ゴライアス
-- 效果：
-- 连接怪兽以外的「无限起动」怪兽1只
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡从场上送去墓地的场合，以自己场上1只超量怪兽为对象才能发动。把这张卡在那只怪兽下面重叠作为超量素材。
-- ②：持有这张卡作为素材中的原本种族是机械族的超量怪兽得到以下效果。
-- ●这张卡不会被效果破坏。
function c23689428.initial_effect(c)
	-- 为卡片添加连接召唤手续，要求使用1个满足条件的怪兽作为连接素材
	aux.AddLinkProcedure(c,c23689428.matfilter,1,1)
	c:EnableReviveLimit()
	-- ①：这张卡从场上送去墓地的场合，以自己场上1只超量怪兽为对象才能发动。把这张卡在那只怪兽下面重叠作为超量素材。
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
-- 过滤连接素材，要求是「无限起动」卡组且不是连接怪兽
function c23689428.matfilter(c)
	return c:IsLinkSetCard(0x127) and not c:IsLinkType(TYPE_LINK)
end
-- 判断此卡是否从场上离开（而非从手牌或额外卡组）
function c23689428.xyzcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤场上存在的超量怪兽
function c23689428.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 设置效果目标选择函数，用于选择场上一只超量怪兽作为对象
function c23689428.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c23689428.filter(chkc) end
	-- 检查是否满足发动条件，即场上存在一只超量怪兽且此卡可以作为超量素材
	if chk==0 then return Duel.IsExistingTarget(c23689428.filter,tp,LOCATION_MZONE,0,1,nil)
		and e:GetHandler():IsCanOverlay() end
	-- 向玩家提示选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择一只超量怪兽作为效果对象
	Duel.SelectTarget(tp,c23689428.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置连锁操作信息，表示将此卡从墓地移除
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 执行效果操作，将此卡叠放在选中的超量怪兽下面
function c23689428.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) and c:IsRelateToEffect(e) and c:IsCanOverlay() then
		-- 将此卡叠放至目标怪兽下方
		Duel.Overlay(tc,Group.FromCards(c))
	end
end
-- 判断此卡是否作为超量素材且原本种族为机械族
function c23689428.condition(e)
	return e:GetHandler():GetOriginalRace()==RACE_MACHINE
end
