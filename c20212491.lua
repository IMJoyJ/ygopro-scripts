--ストレイ・ピュアリィ・ストリート
-- 效果：
-- ①：自己场上的「纯爱妖精」怪兽在特殊召唤的回合不会成为对方的效果的对象。
-- ②：1回合1次，自己场上的表侧表示的「纯爱妖精」超量怪兽因对方从场上离开的场合发动。从自己的卡组·墓地选1只1星「纯爱妖精」怪兽特殊召唤。
-- ③：双方的结束阶段，以场上1只「纯爱妖精」超量怪兽为对象才能发动。从自己的卡组·墓地选1张「纯爱妖精」速攻魔法卡在那只怪兽下面重叠作为超量素材。
local s,id,o=GetID()
-- 注册场地魔法卡的发动效果和三个连锁效果，分别对应①②③效果
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 自己场上的「纯爱妖精」怪兽在特殊召唤的回合不会成为对方的效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.immtg)
	-- 设置效果值为aux.tgoval函数，用于判断是否能成为对方效果的对象
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- 1回合1次，自己场上的表侧表示的「纯爱妖精」超量怪兽因对方从场上离开的场合发动。从自己的卡组·墓地选1只1星「纯爱妖精」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	-- 双方的结束阶段，以场上1只「纯爱妖精」超量怪兽为对象才能发动。从自己的卡组·墓地选1张「纯爱妖精」速攻魔法卡在那只怪兽下面重叠作为超量素材。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"补充超量素材"
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetRange(LOCATION_FZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetTarget(s.mattg)
	e4:SetOperation(s.matop)
	c:RegisterEffect(e4)
end
-- 过滤函数，判断目标怪兽是否为「纯爱妖精」且在本回合被特殊召唤
function s.immtg(e,c)
	return c:IsSetCard(0x18c) and c:IsStatus(STATUS_SPSUMMON_TURN)
end
-- 过滤函数，判断离场的怪兽是否为「纯爱妖精」超量怪兽且为对方造成离场
function s.spcfilter(c,tp)
	return c:IsSetCard(0x18c) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousPosition(POS_FACEUP) and c:GetReasonPlayer()==1-tp and c:IsType(TYPE_XYZ)
		and not c:IsReason(REASON_RULE)
end
-- 条件函数，判断是否有满足条件的怪兽离场
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.spcfilter,1,nil,tp)
end
-- 过滤函数，判断是否为1星「纯爱妖精」怪兽且可特殊召唤
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x18c) and c:IsLevel(1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的目标信息，表示从卡组或墓地选择1只怪兽特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 处理特殊召唤效果，选择并特殊召唤符合条件的怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<1 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组或墓地选择满足条件的1只怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数，判断是否为可作为超量素材的「纯爱妖精」速攻魔法卡
function s.matfilter2(c)
	return c:IsCanOverlay() and c:IsType(TYPE_QUICKPLAY) and c:IsSetCard(0x18c)
end
-- 过滤函数，判断是否为「纯爱妖精」超量怪兽且场上存在可作为素材的速攻魔法卡
function s.matfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x18c) and c:IsType(TYPE_XYZ)
		-- 判断场上是否存在可作为超量素材的速攻魔法卡
		and Duel.IsExistingMatchingCard(s.matfilter2,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,nil)
end
-- 设置超量素材效果的目标选择，选择1只「纯爱妖精」超量怪兽作为对象
function s.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.matfilter(chkc,tp) end
	-- 检查是否存在满足条件的「纯爱妖精」超量怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(s.matfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择1只「纯爱妖精」超量怪兽作为对象
	Duel.SelectTarget(tp,s.matfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
end
-- 处理超量素材效果，选择并叠放速攻魔法卡作为超量素材
function s.matop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and not tc:IsImmuneToEffect(e) then
		-- 提示玩家选择要作为超量素材的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
		-- 从卡组或墓地选择1张满足条件的速攻魔法卡
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.matfilter2),tp,LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil,tc)
		if #g>0 then
			-- 将选中的速攻魔法卡叠放至目标怪兽上
			Duel.Overlay(tc,g)
		end
	end
end
