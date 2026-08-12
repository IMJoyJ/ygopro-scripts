--生命の汞 メルクリウム
-- 效果：
-- 10星怪兽×2只以上
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡超量召唤的场合才能发动。从卡组把1只怪兽作为这张卡的超量素材。
-- ②：只要持有超量素材的这张卡在怪兽区域存在，持有和自己墓地的怪兽的其中任意种相同属性的对方墓地的怪兽的效果不能发动。
-- ③：自己·对方的结束阶段发动。这张卡1个超量素材取除或自己受到3000伤害。
local s,id,o=GetID()
-- 初始化卡片效果：设定超量召唤手续和苏生限制，并注册①超量召唤成功时获取超量素材的诱发选发效果、②使对方墓地特定怪兽效果不能发动的永续效果、③结束阶段取除素材或受到伤害的诱发必发效果
function s.initial_effect(c)
	-- 设定这张卡的超量召唤手续：用等级10的怪兽2只以上（最多99只）进行叠放
	aux.AddXyzProcedure(c,nil,10,2,nil,nil,99)
	c:EnableReviveLimit()
	-- ①：这张卡超量召唤的场合才能发动。从卡组把1只怪兽作为这张卡的超量素材。这个卡名的①的效果1回合只能使用1次。
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
	-- ②：只要持有超量素材的这张卡在怪兽区域存在，持有和自己墓地的怪兽的其中任意种相同属性的对方墓地的怪兽的效果不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetCondition(s.limcon)
	e2:SetValue(s.limval)
	c:RegisterEffect(e2)
	-- ③：自己·对方的结束阶段发动。这张卡1个超量素材取除或自己受到3000伤害。
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
-- 效果①的发动条件：这张卡是超量召唤成功的场合
function s.mtcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 素材获取效果的过滤函数：可作为超量素材、且不受此效果影响的怪兽卡
function s.mtfilter(c,e)
	return c:IsType(TYPE_MONSTER)
		and c:IsCanOverlay() and not (e and c:IsImmuneToEffect(e))
end
-- 效果①发动目标的检测：这张卡是超量怪兽且卡组存在可以作为超量素材的怪兽
function s.mttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ)
		-- 检测自己卡组是否存在至少1只满足条件的可以作为超量素材的怪兽
		and Duel.IsExistingMatchingCard(s.mtfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向对方玩家提示我方发动了「获取超量素材」的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 效果①的处理：确认这张卡仍与连锁关联后，让玩家从卡组选择1只怪兽作为这张卡的超量素材叠放
function s.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	-- 提示玩家「请选择要作为超量素材的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 让玩家从自己卡组选择1只满足条件的可以作为超量素材的怪兽
	local g=Duel.SelectMatchingCard(tp,s.mtfilter,tp,LOCATION_DECK,0,1,1,nil,e)
	if g:GetCount()>0 then
		-- 将选择的怪兽作为这张卡的超量素材叠放
		Duel.Overlay(c,g)
	end
end
-- 属性判定的过滤函数：这张卡的属性与指定怪兽的属性相同
function s.cfilter(c,ec)
	return c:IsAttribute(ec:GetAttribute())
end
-- 效果②的适用条件：这张卡持有超量素材
function s.limcon(e)
	return e:GetHandler():GetOverlayCount()>0
end
-- 效果②的判定：发动中的效果来自墓地的怪兽，且自己墓地存在与其属性相同的怪兽时，该效果不能发动
function s.limval(e,re,rp)
	local rc=re:GetHandler()
	return rc:IsLocation(LOCATION_GRAVE) and re:IsActiveType(TYPE_MONSTER)
		-- 检测自己墓地是否存在至少1只与发动效果的怪兽属性相同的怪兽
		and Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil,rc)
end
-- 效果③的目标处理：若这张卡没有超量素材则预设伤害操作信息，并向对方提示发动了「取除素材或伤害」的效果
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if e:GetHandler():GetOverlayCount()==0 then
		-- 设定效果处理时将给自己造成3000点伤害的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,3000)
	end
	-- 向对方玩家提示我方发动了「取除素材或伤害」的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 效果③的处理：若可以取除超量素材且玩家选择取除，则取除这张卡1个超量素材，否则自己受到3000点伤害
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断这张卡能否取除1个超量素材，并询问玩家是否要取除超量素材
	if e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_EFFECT) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否要取除超量素材？"
		e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_EFFECT)
	else
		-- 自己受到3000点效果伤害
		Duel.Damage(tp,3000,REASON_EFFECT)
	end
end
