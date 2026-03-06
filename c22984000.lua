--Mercurium the Living Quicksilver
-- 效果：
-- 10星怪兽×2只以上
-- 这张卡超量召唤的场合：可以从卡组把1只怪兽作为这张卡的超量素材。「鲜活水银 汞合兽」的这个效果1回合只能使用1次。
-- 只要这张卡持有超量素材，对方不能把自身墓地的，和自己墓地的怪兽相同属性的怪兽的效果发动。
-- 1回合1次，结束阶段：这张卡1个超量素材取除或者自己受到3000伤害。
local s,id,o=GetID()
-- 初始化效果函数，设置XYZ召唤程序、启用复活限制并注册三个效果
function s.initial_effect(c)
	-- 添加XYZ召唤手续，要求使用至少2只10星怪兽进行超量召唤
	aux.AddXyzProcedure(c,nil,10,2,nil,nil,99)
	c:EnableReviveLimit()
	-- 效果1：这张卡超量召唤成功的场合
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"获取超量素材"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.mtcon)
	e1:SetTarget(s.mttg)
	e1:SetOperation(s.mtop)
	c:RegisterEffect(e1)
	-- 效果2：只要这张卡持有超量素材，对方不能把自身墓地的，和自己墓地的怪兽相同属性的怪兽的效果发动
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetCondition(s.limcon)
	e2:SetValue(s.limval)
	c:RegisterEffect(e2)
	-- 效果3：结束阶段：这张卡1个超量素材取除或者自己受到3000伤害
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"取除素材或伤害"
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.rmtg)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)
end
-- 条件函数：判断是否为XYZ召唤
function s.mtcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 过滤函数：用于选择可作为超量素材的怪兽
function s.mtfilter(c,e)
	return c:IsType(TYPE_MONSTER)
		and c:IsCanOverlay() and not (e and c:IsImmuneToEffect(e))
end
-- 目标函数：检查是否可以发动效果
function s.mttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ)
		-- 检查卡组中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.mtfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示对方玩家选择了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 效果处理函数：从卡组选择怪兽作为超量素材
function s.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	-- 提示玩家选择作为超量素材的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 选择满足条件的怪兽作为超量素材
	local g=Duel.SelectMatchingCard(tp,s.mtfilter,tp,LOCATION_DECK,0,1,1,nil,e)
	if g:GetCount()>0 then
		-- 将选中的怪兽叠放至该卡上
		Duel.Overlay(c,g)
	end
end
-- 属性过滤函数：判断墓地怪兽是否与目标怪兽属性相同
function s.cfilter(c,ec)
	return c:IsAttribute(ec:GetAttribute())
end
-- 条件函数：判断该卡是否持有超量素材
function s.limcon(e)
	return e:GetHandler():GetOverlayCount()>0
end
-- 限制值函数：判断对方是否能发动墓地中的怪兽效果
function s.limval(e,re,rp)
	local rc=re:GetHandler()
	return rc:IsLocation(LOCATION_GRAVE) and re:IsActiveType(TYPE_MONSTER)
		-- 检查对方墓地是否存在与目标怪兽属性相同的怪兽
		and Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil,rc)
end
-- 目标函数：结束阶段时处理取除素材或造成伤害
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if e:GetHandler():GetOverlayCount()==0 then
		-- 设置操作信息为对玩家造成3000伤害
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,3000)
	end
	-- 提示对方玩家选择了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 效果处理函数：结束阶段时选择取除素材或受到伤害
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否可以取除超量素材并询问玩家选择
	if e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_EFFECT) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否要取除超量素材？"
		e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_EFFECT)
	else
		-- 对玩家造成3000伤害
		Duel.Damage(tp,3000,REASON_EFFECT)
	end
end
