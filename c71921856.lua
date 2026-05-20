--No.79 BK 新星のカイザー
-- 效果：
-- 4星怪兽×2
-- ①：这张卡的攻击力上升这张卡的超量素材数量×100。
-- ②：1回合1次，自己主要阶段才能发动。把自己的手卡·墓地1只「燃烧拳击手」怪兽作为这张卡的超量素材。
-- ③：持有超量素材的这张卡被对方破坏送去墓地时，以最多有这张卡持有的超量素材数量的自己墓地的4星以下的「燃烧拳击手」怪兽为对象才能发动。那些怪兽特殊召唤。
function c71921856.initial_effect(c)
	-- 添加XYZ召唤手续：4星怪兽×2
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ②：1回合1次，自己主要阶段才能发动。把自己的手卡·墓地1只「燃烧拳击手」怪兽作为这张卡的超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(71921856,0))  --"补充素材"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c71921856.target)
	e1:SetOperation(c71921856.operation)
	c:RegisterEffect(e1)
	-- ①：这张卡的攻击力上升这张卡的超量素材数量×100。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(c71921856.atkval)
	c:RegisterEffect(e2)
	-- ③：持有超量素材的这张卡被对方破坏送去墓地时，以最多有这张卡持有的超量素材数量的自己墓地的4星以下的「燃烧拳击手」怪兽为对象才能发动。那些怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(71921856,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCondition(c71921856.spcon)
	e3:SetTarget(c71921856.sptg)
	e3:SetOperation(c71921856.spop)
	c:RegisterEffect(e3)
end
-- 设置该怪兽的「No.」编号为79
aux.xyz_number[71921856]=79
-- 过滤条件：手卡·墓地的「燃烧拳击手」怪兽，且可以作为超量素材
function c71921856.filter(c)
	return c:IsSetCard(0x1084) and c:IsType(TYPE_MONSTER) and c:IsCanOverlay()
end
-- 效果②的发动准备与合法性检测
function c71921856.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ)
		-- 检查自己手卡或墓地是否存在至少1只满足条件的「燃烧拳击手」怪兽
		and Duel.IsExistingMatchingCard(c71921856.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil) end
end
-- 效果②的效果处理：选择1只「燃烧拳击手」怪兽作为这张卡的超量素材
function c71921856.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 提示玩家选择要作为超量素材的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 玩家从手卡或墓地选择1只满足条件的「燃烧拳击手」怪兽（受王家之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c71921856.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽重叠作为这张卡的超量素材
		Duel.Overlay(c,g)
	end
end
-- 计算并返回攻击力上升值：超量素材数量×100
function c71921856.atkval(e,c)
	return c:GetOverlayCount()*100
end
-- 效果③的发动条件：持有超量素材的这张卡在怪兽区域被对方破坏并送去墓地
function c71921856.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetPreviousOverlayCountOnField()
	e:SetLabel(ct)
	return c:IsReason(REASON_DESTROY) and c:GetReasonPlayer()==1-tp
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp) and ct>0
end
-- 过滤条件：自己墓地的4星以下的「燃烧拳击手」怪兽，且可以特殊召唤
function c71921856.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x1084) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果③的发动准备与取对象处理
function c71921856.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c71921856.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足特殊召唤条件的4星以下「燃烧拳击手」怪兽
		and Duel.IsExistingTarget(c71921856.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	local ct=e:GetLabel()
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ct>ft then ct=ft end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择最多等同于原超量素材数量（且不超过可用怪兽区域数）的墓地怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c71921856.spfilter,tp,LOCATION_GRAVE,0,1,ct,nil,e,tp)
	-- 设置连锁的操作信息，表示此效果包含特殊召唤选定怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
end
-- 效果③的效果处理：将作为对象的怪兽特殊召唤
function c71921856.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取仍与效果关联的作为对象的怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 再次获取当前自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	if ft<g:GetCount() then return end
	if g:GetCount()>0 then
		-- 将选定的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
