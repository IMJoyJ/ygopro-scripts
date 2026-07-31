--CX 冀望皇龍カオス・バリアン・ドラゴン
local s,id,o=GetID()
-- 初始化卡片效果：注册超量召唤手续、素材数量攻击力上升、持CNo.素材封锁加手、取除素材重叠对方卡组顶卡片效果
function s.initial_effect(c)
	aux.AddXyzProcedure(c,nil,7,3,s.ovfilter,aux.Stringid(id,0),99)
	c:EnableReviveLimit()
	-- ①：这张卡的攻击力上升这张卡的超量素材数量×1000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	-- ②：只要这张卡有「CNo.」怪兽在作为超量素材，对方不能从卡组把卡加入手牌。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_TO_HAND)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCondition(s.nscon)
	e2:SetTargetRange(0,1)
	-- 封锁目标：限制从卡组加入手牌的行为
	e2:SetTarget(aux.TargetBoolFunction(Card.IsLocation,LOCATION_DECK))
	c:RegisterEffect(e2)
	-- ③：1回合1次，把这张卡1个超量素材取除才能发动。对方卡组最上面的2张卡在这张卡下面重叠作为超量素材。
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
-- 超量叠放条件：场上表侧表示的No.101~No.107的「CNo.」怪兽
function s.ovfilter(c)
	-- 获取卡片的No.编号
	local no=aux.GetXyzNumber(c)
	return c:IsFaceup() and no and no>=101 and no<=107 and c:IsSetCard(0x1048)
end
-- 计算攻击力上升值：自身超量素材数量×1000
function s.atkval(e,c)
	return c:GetOverlayCount()*1000
end
-- 过滤条件：「CNo.」怪兽卡
function s.cfilter(c)
	return c:IsSetCard(0x1048) and c:IsType(TYPE_MONSTER)
end
-- 封锁效果生效条件：自身的超量素材中存在「CNo.」怪兽
function s.nscon(e)
	return e:GetHandler():GetOverlayGroup():IsExists(s.cfilter,1,nil)
end
-- 增加素材效果Cost：取除自身1个超量素材
function s.mtcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 增加素材效果发动条件检查：自身为超量怪兽且对方卡组数量大于1
function s.mttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自身是超量怪兽且对方卡组至少有2张卡
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ) and Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)>1 end
end
-- 增加素材效果处理：将对方卡组顶2张卡作为超量素材重叠至自身下方，不可重叠的送去墓地
function s.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方卡组最上方的2张卡
	local g=Duel.GetDecktopGroup(1-tp,2)
	if c:IsRelateToChain() and g:GetCount()>0 then
		local og=Group.CreateGroup()
		local sg=Group.CreateGroup()
		-- 遍历卡组顶的2张卡，分类可重叠为超量素材与不可重叠的卡
		for tc in aux.Next(g) do
			if tc:IsCanOverlay() then
				og:AddCard(tc)
			else
				sg:AddCard(tc)
			end
		end
		if og:GetCount()>0 then
			-- 禁用洗牌检查（防止将卡组顶卡片变成素材时触发自动洗牌）
			Duel.DisableShuffleCheck()
			-- 将符合条件的卡片作为超量素材重叠至自身下方
			Duel.Overlay(c,og)
		end
		if sg:GetCount()>0 then
			-- 禁用洗牌检查
			Duel.DisableShuffleCheck()
			-- 将无法作为超量素材的卡因规则送去墓地
			Duel.SendtoGrave(sg,REASON_RULE)
		end
	end
end
