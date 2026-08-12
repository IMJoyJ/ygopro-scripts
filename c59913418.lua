--終焉の覇王デミス
-- 效果：
-- 「世界不灭」降临
-- ①：这张卡的卡名只要在手卡·场上存在当作「终焉之王 迪米斯」使用。
-- ②：只要仪式召唤的这张卡在怪兽区域存在，自己的仪式怪兽不会被战斗破坏。
-- ③：为只使用仪式怪兽作仪式召唤的这张卡的效果发动而支付的基本分变成不需要。
-- ④：1回合1次，支付2000基本分才能发动。场上的其他卡全部破坏，给与对方破坏的对方场上的卡数量×200伤害。
function c59913418.initial_effect(c)
	-- 记录此卡记述了「世界不灭」的卡名事实，以支持相关检索判定
	aux.AddCodeList(c,32828635)
	c:EnableReviveLimit()
	-- 只要这张卡在手卡·怪兽区域存在，卡名当作「终焉之王 迪米斯」使用
	aux.EnableChangeCode(c,72426662,LOCATION_MZONE+LOCATION_HAND)
	-- ②：只要仪式召唤的这张卡在怪兽区域存在，自己的仪式怪兽不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(c59913418.indcon)
	e2:SetTarget(c59913418.indtg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ③：为只使用仪式怪兽作仪式召唤的这张卡的效果发动而支付的基本分变成不需要。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_LPCOST_CHANGE)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e0:SetRange(LOCATION_MZONE)
	e0:SetTargetRange(1,1)
	e0:SetCondition(c59913418.costcon)
	e0:SetValue(c59913418.costval)
	c:RegisterEffect(e0)
	-- ④：1回合1次，支付2000基本分才能发动。场上的其他卡全部破坏，给与对方破坏的对方场上的卡数量×200伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(c59913418.descost)
	e3:SetTarget(c59913418.destg)
	e3:SetOperation(c59913418.desop)
	c:RegisterEffect(e3)
	-- ③：为只使用仪式怪兽作仪式召唤的这张卡的效果发动而支付的基本分变成不需要。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCondition(c59913418.matcon)
	e4:SetOperation(c59913418.matop)
	c:RegisterEffect(e4)
	-- ③：为只使用仪式怪兽作仪式召唤的这张卡的效果发动而支付的基本分变成不需要。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_MATERIAL_CHECK)
	e5:SetValue(c59913418.valcheck)
	e5:SetLabelObject(e4)
	c:RegisterEffect(e5)
end
-- 战破抗性的发动条件判定：这张卡必须是仪式召唤成功
function c59913418.indcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 战破抗性的对象过滤：目标卡必须是仪式怪兽
function c59913418.indtg(e,c)
	return c:IsType(TYPE_RITUAL)
end
-- 过滤函数：筛选不是仪式怪兽的卡片
function c59913418.mfilter(c)
	return not c:IsType(TYPE_RITUAL)
end
-- 基本分豁免条件的判定：检查这张卡是否带有由只使用仪式怪兽仪式召唤成功所赋予的特定标记
function c59913418.costcon(e)
	return e:GetHandler():GetFlagEffect(59913418)>0
end
-- 基本分豁免的修改函数：若当前正要发动的效果是这张卡自身发动的效果，则将其所需支付的基本分Cost降为0
function c59913418.costval(e,re,rp,val)
	if re and re:IsActivated() and re:GetHandler()==e:GetHandler() then
		return 0
	else return val end
end
-- 效果④的Cost支付判定：检查玩家是否可以支付2000点基本分，如果可以则支付2000点基本分
function c59913418.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检查：检查当前玩家是否能够支付2000点生命值
	if chk==0 then return Duel.CheckLPCost(tp,2000) end
	-- 支付2000点生命值作为效果发动的代价
	Duel.PayLPCost(tp,2000)
end
-- 效果④的发动准备与目标计算：检查场上是否存在除这张卡以外的卡，并计算预计对对方造成的伤害
function c59913418.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检查：检查场上是否存在至少1张除这张卡以外的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 获取场上所有除了这张卡以外的其他卡片组
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	local ct=g:FilterCount(Card.IsControler,nil,1-tp)
	-- 设置操作信息：破坏除这张卡以外的所有其他场上卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置操作信息：给与对方玩家由其场上卡片被破坏数量乘以200的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*200)
end
-- 效果④的效果处理：破坏场上除这张卡以外的所有其他卡，统计其中属于对方的被破坏卡片数量，给与对方相应倍数的伤害
function c59913418.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果处理时，场上除了本卡以外的所有其他卡片组
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	-- 因效果将这些卡片全部破坏
	Duel.Destroy(g,REASON_EFFECT)
	-- 统计实际被破坏的属于对方场上的卡片数量
	local ct=Duel.GetOperatedGroup():FilterCount(Card.IsControler,nil,1-tp)
	if ct>0 then
		-- 给予对方玩家对应的伤害值
		Duel.Damage(1-tp,ct*200,REASON_EFFECT)
	end
end
-- 检查召唤方式为仪式召唤，且素材标记显示仅使用了仪式怪兽
function c59913418.matcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL) and e:GetLabel()==1
end
-- 在仪式召唤成功时给此卡注册特定标记效果，表示其符合免除基本分Cost的条件
function c59913418.matop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(59913418,RESET_EVENT+RESETS_STANDARD,0,1)
end
-- 素材检查函数：获取该卡的仪式素材，若素材中没有非仪式怪兽，则将对应标记的值设为1以传达给后续效果判定
function c59913418.valcheck(e,c)
	local g=c:GetMaterial()
	if g:GetCount()>0 and not g:IsExists(c59913418.mfilter,1,nil) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
