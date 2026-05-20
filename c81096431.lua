--ドレイク・シャーク
--not fully implemented
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡用抽卡以外的方法加入手卡的场合才能发动。这张卡特殊召唤。
-- ②：以怪兽3只以上为素材的水属性超量怪兽超量召唤的场合，这张卡可以作为2只数量的超量素材。
-- ③：持有这张卡作为素材中的「鲨龙兽」超量怪兽得到以下效果。
-- ●1回合1次，把这张卡2个超量素材取除，以场上1张魔法·陷阱卡为对象才能发动。那张卡作为这张卡的超量素材。
local s,id,o=GetID()
-- 注册卡片效果：①手卡特召，②作为2个超量素材，③赋予「鲨龙兽」超量怪兽效果
function s.initial_effect(c)
	-- ①：这张卡用抽卡以外的方法加入手卡的场合才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：以怪兽3只以上为素材的水属性超量怪兽超量召唤的场合，这张卡可以作为2只数量的超量素材。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_DOUBLE_XMATERIAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.sxyzfilter)
	e2:SetValue(id)
	e2:SetCountLimit(1,id+o)
	c:RegisterEffect(e2)
	-- ③：持有这张卡作为素材中的「鲨龙兽」超量怪兽得到以下效果。●1回合1次，把这张卡2个超量素材取除，以场上1张魔法·陷阱卡为对象才能发动。那张卡作为这张卡的超量素材。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"获取超量素材（龙兽鲨）"
	e3:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.xyzcon)
	e3:SetCost(s.xyzcost)
	e3:SetTarget(s.xyztg)
	e3:SetOperation(s.xyzop)
	c:RegisterEffect(e3)
end
-- 过滤超量召唤的怪兽，限定为水属性怪兽
function s.sxyzfilter(e,c)
	return c:IsAttribute(ATTRIBUTE_WATER)
end
-- 检查加入手卡的原因是否不是抽卡
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsReason(REASON_DRAW)
end
-- 特殊召唤效果的靶向与可行性检测，确认怪兽区域有空位且自身可以特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查玩家场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理中的操作信息，声明将特殊召唤1张自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 特殊召唤效果的处理，将自身特殊召唤到场上
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若自身仍与效果相关联，则以表侧表示特殊召唤到发动效果的玩家场上
	if c:IsRelateToEffect(e) then Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end
end
-- 检查获得效果的怪兽是否为「鲨龙兽」超量怪兽
function s.xyzcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSetCard(0x11b8) and c:IsType(TYPE_XYZ)
end
-- 过滤场上的魔法·陷阱卡，且该卡必须能够作为超量素材
function s.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsCanOverlay()
end
-- 移除超量素材效果的代价处理，取除自身2个超量素材
function s.xyzcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- 吸收魔法·陷阱卡为素材效果的靶向检测，确认自身是超量怪兽且场上有可作为素材的魔法·陷阱卡
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and s.filter(chkc) and chkc~=e:GetHandler() end
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ)
		-- 检查场上是否存在除自身以外、可作为超量素材的魔法·陷阱卡
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 给玩家发送提示信息，提示选择要作为超量素材的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 玩家选择场上1张魔法·陷阱卡作为效果的对象
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 向对方玩家提示当前发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 吸收魔法·陷阱卡为素材效果的具体处理
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择为对象的魔法·陷阱卡
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		tc:CancelToGrave()
		-- 将目标卡重叠作为自身的超量素材
		Duel.Overlay(c,Group.FromCards(tc))
	end
end
