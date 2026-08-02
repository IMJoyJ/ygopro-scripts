--CX 冀望皇龍カオス・バリアン・ドラゴン
local s,id,o=GetID()
-- 初始化效果并添加XYZ召唤手续
function s.initial_effect(c)
	aux.AddXyzProcedure(c,nil,7,3,s.ovfilter,aux.Stringid(id,0),99)
	c:EnableReviveLimit()
	-- 这张卡的攻击力上升这张卡的超量素材数量×1000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	-- 只要满足条件，对方不能把卡从卡组加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_TO_HAND)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCondition(s.nscon)
	e2:SetTargetRange(0,1)
	-- 设置不能加入手卡的目标为卡组的卡
	e2:SetTarget(aux.TargetBoolFunction(Card.IsLocation,LOCATION_DECK))
	c:RegisterEffect(e2)
	-- 1回合1次，把这张卡1个超量素材取除才能发动。对方卡组最上方的2张卡作为这张卡的超量素材。不能叠放的卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(s.mtcost)
	e3:SetTarget(s.mttg)
	e3:SetOperation(s.mtop)
	c:RegisterEffect(e3)
end
-- 过滤条件：怪兽是表侧表示且No.编号在101至107之间，且带有特定字段
function s.ovfilter(c)
	-- 获取卡片的No.编号
	local no=aux.GetXyzNumber(c)
	return c:IsFaceup() and no and no>=101 and no<=107 and c:IsSetCard(0x1048)
end
-- 获取攻击力提升数值：超量素材数量乘以1000
function s.atkval(e,c)
	return c:GetOverlayCount()*1000
end
-- 过滤条件：带有特定字段的怪兽卡
function s.cfilter(c)
	return c:IsSetCard(0x1048) and c:IsType(TYPE_MONSTER)
end
-- 效果条件：这张卡的超量素材中存在满足过滤条件的卡
function s.nscon(e)
	return e:GetHandler():GetOverlayGroup():IsExists(s.cfilter,1,nil)
end
-- 效果代价：检查能否取除1个超量素材，并取除1个超量素材
function s.mtcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果目标：检查此卡是否是超量怪兽且对方卡组至少有2张卡
function s.mttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查这是否是超量怪兽以及对方卡组数量是否大于1张
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ) and Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)>1 end
end
-- 效果处理：获取对方卡组最上方2张卡，将其作为超量素材，不能重叠的送去墓地
function s.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方卡组最上方的2张卡
	local g=Duel.GetDecktopGroup(1-tp,2)
	if c:IsRelateToChain() and g:GetCount()>0 then
		local og=Group.CreateGroup()
		local sg=Group.CreateGroup()
		-- 遍历对方卡组最上方的这2张卡
		for tc in aux.Next(g) do
			if tc:IsCanOverlay() then
				og:AddCard(tc)
			else
				sg:AddCard(tc)
			end
		end
		if og:GetCount()>0 then
			-- 禁用下一个操作的洗牌检测
			Duel.DisableShuffleCheck()
			-- 把卡片作为这张卡的超量素材叠放
			Duel.Overlay(c,og)
		end
		if sg:GetCount()>0 then
			-- 禁用下一个操作的洗牌检测
			Duel.DisableShuffleCheck()
			-- 把不能叠放的卡按规则送去墓地
			Duel.SendtoGrave(sg,REASON_RULE)
		end
	end
end
