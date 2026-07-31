--CX 冀望皇龍カオス・バリアン・ドラゴン
local s,id,o=GetID()
-- 初始化卡片效果：注册超量召唤手续、根据超量素材增加攻击力效果、超量素材包含「CNo.」时封锁对方卡组检索/抽牌效果、去除1个素材吸收对方卡组顶2张卡为素材效果
function s.initial_effect(c)
	aux.AddXyzProcedure(c,nil,7,3,s.ovfilter,aux.Stringid(id,0),99)
	c:EnableReviveLimit()
	-- ①：此卡的攻击力上升此卡的超量素材数量×1000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	-- ②：只要此卡有「CNo.」怪兽在作为超量素材，对方不能从卡组把卡加入手牌。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_TO_HAND)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCondition(s.nscon)
	e2:SetTargetRange(0,1)
	-- 限制目标区域：针对卡组区域的卡片生效（阻止从卡组加入手牌）
	e2:SetTarget(aux.TargetBoolFunction(Card.IsLocation,LOCATION_DECK))
	c:RegisterEffect(e2)
	-- ③：1回合1次，去除此卡1个超量素材才能发动。对方卡组顶2张卡在此卡下面重叠作为超量素材（不能作为超量素材的卡送去墓地）。
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
-- 重叠超量素材过滤条件：表侧表示的「No.101」~「No.107」的「CNo.」怪兽
function s.ovfilter(c)
	-- 获取卡片的「No.」编号
	local no=aux.GetXyzNumber(c)
	return c:IsFaceup() and no and no>=101 and no<=107 and c:IsSetCard(0x1048)
end
-- 攻击力增加量计算：超量素材数量×1000
function s.atkval(e,c)
	return c:GetOverlayCount()*1000
end
-- 超量素材过滤条件：「CNo.」怪兽
function s.cfilter(c)
	return c:IsSetCard(0x1048) and c:IsType(TYPE_MONSTER)
end
-- ②效果生效条件：自身超量素材中存在「CNo.」怪兽
function s.nscon(e)
	return e:GetHandler():GetOverlayGroup():IsExists(s.cfilter,1,nil)
end
-- ③效果发动Cost：去除自身1个超量素材
function s.mtcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ③效果发动准备：检查自身为超量怪兽且对方卡组数量大于1张
function s.mttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自身是否为超量怪兽且对方卡组顶至少有2张卡
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ) and Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)>1 end
end
-- ③效果处理：获取对方卡组顶2张卡，能作为超量素材的卡重叠至自身之下，其余卡因规则送去墓地
function s.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方卡组顶2张卡
	local g=Duel.GetDecktopGroup(1-tp,2)
	if c:IsRelateToChain() and g:GetCount()>0 then
		local og=Group.CreateGroup()
		local sg=Group.CreateGroup()
		-- 遍历对方卡组顶选取的卡，按能否作为超量素材分类
		for tc in aux.Next(g) do
			if tc:IsCanOverlay() then
				og:AddCard(tc)
			else
				sg:AddCard(tc)
			end
		end
		if og:GetCount()>0 then
			-- 禁用洗牌检查（防止对卡组实施洗牌）
			Duel.DisableShuffleCheck()
			-- 将可作为超量素材的卡重叠至此卡之下作为超量素材
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
