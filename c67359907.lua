--超征竜－ディザスター
-- 效果：
-- 7阶怪兽×2
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡超量召唤的场合，以自己的墓地·除外状态的最多4只7星「征龙」怪兽为对象才能发动。那些怪兽作为这张卡的超量素材。那之后，可以把持有和给这张卡作为超量素材中的怪兽相同属性的怪兽从对方的场上·墓地全部除外。
-- ②：有光·暗·地·水·炎·风属性的「征龙」怪兽全部在作为超量素材中的这张卡攻击力·守备力上升4600，不受其他卡的效果影响。
local s,id,o=GetID()
-- 注册卡片效果，包括超量召唤手续、①效果（超量召唤成功时将墓地/除外的征龙作为素材并除外对方场上/墓地同属性怪兽）、②效果（特定素材存在时不受其他卡效果影响且攻守上升4600）。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加超量召唤手续：7阶怪兽×2
	aux.AddXyzProcedureLevelFree(c,s.mfilter,nil,2,2)
	-- ①：这张卡超量召唤的场合，以自己的墓地·除外状态的最多4只7星「征龙」怪兽为对象才能发动。那些怪兽作为这张卡的超量素材。那之后，可以把持有和给这张卡作为超量素材中的怪兽相同属性的怪兽从对方的场上·墓地全部除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"获取素材"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.mtcon)
	e1:SetTarget(s.mttg)
	e1:SetOperation(s.mtop)
	c:RegisterEffect(e1)
	-- ②：有光·暗·地·水·炎·风属性的「征龙」怪兽全部在作为超量素材中的这张卡……不受其他卡的效果影响。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetValue(s.efilter)
	e2:SetCondition(s.effcon)
	c:RegisterEffect(e2)
	-- ②：有光·暗·地·水·炎·风属性的「征龙」怪兽全部在作为超量素材中的这张卡攻击力·守备力上升4600……
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.effcon)
	e3:SetValue(4600)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
end
-- 判断是否为超量召唤成功，作为①效果的发动条件
function s.mtcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 过滤超量素材：7阶超量怪兽
function s.mfilter(c,xyzc)
	return c:IsXyzType(TYPE_XYZ) and c:IsRank(7)
end
-- 过滤可以作为超量素材的、自己墓地或除外状态的7星「征龙」怪兽
function s.matfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x1c4) and c:IsLevel(7) and c:IsCanOverlay()
end
-- ①效果的发动准备：选择自己墓地·除外状态的最多4只7星「征龙」怪兽作为对象，若有墓地的卡则设置离开墓地的操作信息
function s.mttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.matfilter(chkc) end
	-- 检查自己墓地或除外状态是否存在至少1只满足条件的「征龙」怪兽
	if chk==0 then return Duel.IsExistingTarget(s.matfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要作为超量素材的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 选择自己墓地·除外状态的1到4只满足条件的「征龙」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.matfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,4,nil)
	local gg=g:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	if gg:GetCount()>0 then
		-- 设置操作信息：将选中的墓地卡片移出墓地
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,gg,gg:GetCount(),0,0)
	end
end
-- 过滤效果处理时仍与效果相关且可以作为超量素材的卡
function s.mtfilter(c,e)
	return c:IsRelateToEffect(e) and c:IsCanOverlay()
end
-- 过滤对方场上·墓地中，与当前超量素材具有相同属性且可以被除外的怪兽
function s.rmfilter(c,xg)
	return c:IsType(TYPE_MONSTER) and xg:IsExists(Card.IsAttribute,1,nil,c:GetAttribute()) and c:IsAbleToRemove() and c:IsFaceupEx()
end
-- ①效果的处理：将作为对象的怪兽重叠作为这张卡的超量素材，之后可以把对方场上·墓地持有和超量素材中怪兽相同属性的怪兽全部除外
function s.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中仍与效果相关且可以作为超量素材的对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(s.mtfilter,nil,e)
	if c:IsRelateToEffect(e) and g:GetCount()>0 then
		-- 将目标卡片重叠作为这张卡的超量素材
		Duel.Overlay(c,g)
		-- 立即刷新场地信息，确保超量素材状态更新
		Duel.AdjustAll()
		local xg=c:GetOverlayGroup()
		-- 检查对方场上·墓地是否存在相同属性的怪兽，并询问玩家是否进行除外
		if Duel.IsExistingMatchingCard(s.rmfilter,tp,0,LOCATION_GRAVE+LOCATION_MZONE,1,nil,xg) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否再把怪兽除外？"
			-- 获取对方场上·墓地所有与当前超量素材相同属性的怪兽
			local rg=Duel.GetMatchingGroup(s.rmfilter,tp,0,LOCATION_GRAVE+LOCATION_MZONE,nil,xg)
			if rg:GetCount()>0 then
				-- 中断当前效果，使后续的除外处理与重叠素材不视为同时处理
				Duel.BreakEffect()
				-- 以效果将符合条件的怪兽全部表侧表示除外
				Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
			end
		end
	end
end
-- 过滤属于「征龙」系列的怪兽
function s.attfilter(c)
	return c:IsSetCard(0x1c4) and c:IsType(TYPE_MONSTER)
end
-- ②效果的适用条件：检查这张卡的超量素材中是否集齐了地、水、炎、风、光、暗属性的「征龙」怪兽
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetOverlayGroup()
	local att=0
	-- 遍历这张卡的所有超量素材
	for tc in aux.Next(g) do
		if s.attfilter(tc) then
			att=att|tc:GetAttribute()
		end
	end
	local gattr=ATTRIBUTE_EARTH|ATTRIBUTE_WATER|ATTRIBUTE_FIRE|ATTRIBUTE_WIND|ATTRIBUTE_LIGHT|ATTRIBUTE_DARK
	return att&gattr==gattr
end
-- 免疫效果的过滤条件：不受自身以外的其他卡的效果影响
function s.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
