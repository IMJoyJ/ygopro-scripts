--メレオロジック・アグリゲーター
-- 效果：
-- 9星怪兽×2只以上
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡超量召唤的场合才能发动。从额外卡组把1只怪兽送去墓地。
-- ②：以最多有这张卡的超量素材数量的自己墓地的怪兽为对象才能发动。作为对象的怪兽数量的这张卡的超量素材取除，把作为对象的怪兽作为这张卡的超量素材。
-- ③：这张卡被送去墓地的场合，以场上1张表侧表示卡为对象才能发动。那张卡的效果直到回合结束时无效。
local s,id,o=GetID()
-- 初始化卡片效果：设置超量召唤条件（9星怪兽2只以上），并注册①超量召唤成功时从额外卡组把1只怪兽送去墓地、②起动效果以自己墓地怪兽为对象取除素材并叠放、③被送去墓地时无效场上表侧卡的效果，各效果每回合各限1次。
function s.initial_effect(c)
	-- 为这张卡添加超量召唤手续：需要9星怪兽2只以上作为超量素材（最多99只）。
	aux.AddXyzProcedure(c,nil,9,2,nil,nil,99)
	c:EnableReviveLimit()
	-- ①：这张卡超量召唤的场合才能发动。从额外卡组把1只怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.tgcon)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	-- ②：以最多有这张卡的超量素材数量的自己墓地的怪兽为对象才能发动。作为对象的怪兽数量的这张卡的超量素材取除，把作为对象的怪兽作为这张卡的超量素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.mttg)
	e2:SetOperation(s.mtop)
	c:RegisterEffect(e2)
	-- ③：这张卡被送去墓地的场合，以场上1张表侧表示卡为对象才能发动。那张卡的效果直到回合结束时无效。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o*2)
	e3:SetTarget(s.negtg)
	e3:SetOperation(s.negop)
	c:RegisterEffect(e3)
end
-- ①效果的发动条件：判定这张卡是否以超量召唤方式特殊召唤成功。
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- ①效果的目标阶段：检查自己的额外卡组是否存在可送去墓地的怪兽，若有则登记‘送去墓地’的操作信息。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- ①效果发动合法性检查：自己的额外卡组存在至少1张可以被效果送去墓地的怪兽卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_EXTRA,0,1,nil) end
	-- 登记本次效果处理时将1张卡从额外卡组送去墓地的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA)
end
-- ①效果处理：从额外卡组选择1只怪兽送去墓地，若选择成功则将其送去墓地。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出‘请选择要送去墓地的卡’的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己的额外卡组中选择1张可以送去墓地的怪兽卡。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡以效果原因送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 定义可作为②效果对象的墓地怪兽的过滤条件：必须是怪兽卡且可以作为超量素材叠放。
function s.matfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanOverlay()
end
-- ②效果的发动检查：获取这张卡并读取其超量素材数量；对已选择的对象，验证其为自己墓地的可叠放怪兽；发动时确认有超量素材、墓地存在可叠放怪兽且这张卡能移除超量素材。
function s.mttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local mat=c:GetOverlayCount()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.matfilter(chkc) end
	-- ②效果的发动合法性：这张卡拥有超量素材，且自己墓地存在可成为超量素材的怪兽。
	if chk==0 then return mat>0 and Duel.IsExistingTarget(s.matfilter,tp,LOCATION_GRAVE,0,1,nil)
		and c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) end
	-- 弹出‘请选择要作为超量素材的卡’的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 选择自己墓地中1只至超量素材数量的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.matfilter,tp,LOCATION_GRAVE,0,1,mat,nil)
	-- 将选择的对象数量记录为连锁参数，供效果处理时使用。
	Duel.SetTargetParam(g:GetCount())
	-- 登记本次效果处理涉及对象卡离开墓地的操作信息，数量为对象张数。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,#g,0,0)
end
-- ②效果处理：若这张卡仍与效果相关且超量素材数量足够，则取除与对象数量相同的超量素材，并把对象怪兽叠放在这张卡下作为超量素材。
function s.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		local mat=c:GetOverlayCount()
		-- 取得②效果发动时选择的对象卡片，并过滤出仍与效果相关的卡片。
		local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
		local num=g:GetCount()
		if num>0 and mat>=num
			and c:RemoveOverlayCard(tp,num,num,REASON_EFFECT)~=0 then
			-- 将有效的对象怪兽作为这张卡的超量素材叠放。
			Duel.Overlay(c,g)
		end
	end
end
-- ③效果的目标阶段：以场上1张表侧表示卡为对象，检查其是否可以被无效化，并登记‘无效效果’的操作信息。
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- ③效果对象合法性检查：对象必须是场上表侧表示且可以被无效的卡。
	if chkc then return chkc:IsOnField() and aux.NegateAnyFilter(chkc) end
	-- ③效果发动合法性检查：场上存在至少1张表侧表示且可以被无效的卡。
	if chk==0 then return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 弹出‘请选择要无效的卡’的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择场上1张表侧表示且可无效的卡作为③效果的对象。
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 登记本次效果处理为无效卡片效果，对象为选择的卡。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- ③效果处理：若对象卡仍表侧表示且与效果相关，则无效其卡片效果与效果发动，直到回合结束；若对象为陷阱怪兽，则额外将其无效为通常陷阱状态。
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得③效果的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e,false) then
		-- 无效与对象卡相关的连锁，持续到回合结束，防止其效果在本次连锁中继续处理。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那张卡的效果直到回合结束时无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那张卡的效果直到回合结束时无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 那张卡的效果直到回合结束时无效。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
	end
end
