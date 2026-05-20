--デス・レジーナ・デーモン
-- 效果：
-- ←9 【灵摆】 9→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：以自己的墓地·除外状态的1张「恶魔」魔法·陷阱卡为对象才能发动。这张卡破坏，作为对象的卡加入手卡。
-- 【怪兽效果】
-- 「恶魔们的玉座」降临
-- 这张卡不用仪式召唤不能特殊召唤。这个卡名的①的怪兽效果1回合只能使用1次。
-- ①：这张卡仪式召唤的场合才能发动。对方场上的魔法·陷阱卡全部破坏。这张卡在额外怪兽区域存在的场合，可以再把对方墓地的魔法·陷阱卡全部除外。
-- ②：额外怪兽区域的这张卡不受其他怪兽的效果影响。
local s,id,o=GetID()
-- 初始化函数，注册卡片效果（仪式召唤限制、灵摆属性、灵摆效果、仪式召唤成功时的破坏/除外效果、额外怪兽区域的怪兽效果免疫）。
function s.initial_effect(c)
	-- 记录这张卡上记载了「恶魔们的玉座」的卡名。
	aux.AddCodeList(c,63679166)
	c:EnableReviveLimit()
	-- 开启灵摆怪兽属性（灵摆召唤及灵摆卡的发动）。
	aux.EnablePendulumAttribute(c)
	-- 这张卡不用仪式召唤不能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	-- 设置特殊召唤限制为仅能通过仪式召唤进行。
	e0:SetValue(aux.ritlimit)
	c:RegisterEffect(e0)
	-- ①：以自己的墓地·除外状态的1张「恶魔」魔法·陷阱卡为对象才能发动。这张卡破坏，作为对象的卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"回收效果"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND)
	e1:SetRange(LOCATION_PZONE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ①：这张卡仪式召唤的场合才能发动。对方场上的魔法·陷阱卡全部破坏。这张卡在额外怪兽区域存在的场合，可以再把对方墓地的魔法·陷阱卡全部除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"破坏效果"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE+CATEGORY_GRAVE_ACTION)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	-- ②：额外怪兽区域的这张卡不受其他怪兽的效果影响。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetCondition(s.efcon)
	e3:SetValue(s.efilter)
	c:RegisterEffect(e3)
end
-- 过滤函数：检索自己墓地或除外状态的表侧表示的「恶魔」魔法·陷阱卡，且该卡能加入手卡。
function s.thfilter(c)
	return c:IsFaceupEx() and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0x45) and c:IsAbleToHand()
end
-- 灵摆效果的发动准备（判定是否满足发动条件、选择对象并设置破坏与加入手卡的操作信息）。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and s.thfilter(chkc) end
	-- 判定是否能选择自己墓地或除外状态的1张符合条件的「恶魔」魔法·陷阱卡作为对象。
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己墓地或除外状态的1张符合条件的「恶魔」魔法·陷阱卡作为效果对象。
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	-- 设置操作信息：破坏自身。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	-- 设置操作信息：将作为对象的卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 灵摆效果的处理（破坏自身，并将作为对象的卡加入手卡）。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择的效果对象。
	local tc=Duel.GetFirstTarget()
	-- 判定自身是否仍存在于连锁中，并成功将其破坏。
	if c:IsRelateToChain() and Duel.Destroy(c,REASON_EFFECT)~=0
		-- 判定对象卡是否仍存在于连锁中，且不受「王家长眠之谷」的影响。
		and tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 将作为对象的卡加入手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 触发条件判定：这张卡是否是通过仪式召唤特殊召唤的。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 过滤函数：检索场上的魔法·陷阱卡。
function s.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 仪式召唤成功时效果的发动准备（判定对方场上是否有魔法·陷阱卡，并设置破坏的操作信息）。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判定对方场上是否存在至少1张魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_ONFIELD,1,c) end
	-- 获取对方场上所有的魔法·陷阱卡。
	local sg=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_ONFIELD,c)
	-- 设置操作信息：破坏对方场上所有的魔法·陷阱卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 过滤函数：检索墓地中可以被除外的魔法·陷阱卡。
function s.rmfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemove()
end
-- 仪式召唤成功时效果的处理（破坏对方场上所有的魔法·陷阱卡，若自身在额外怪兽区域，可选择再将对方墓地的魔法·陷阱卡全部除外）。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方场上所有的魔法·陷阱卡。
	local sg=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_ONFIELD,nil)
	-- 破坏对方场上所有的魔法·陷阱卡，并判定是否成功破坏了至少1张。
	if Duel.Destroy(sg,REASON_EFFECT)~=0
		and c:IsRelateToChain() and c:GetSequence()>4
		-- 判定对方墓地是否存在不受「王家长眠之谷」影响且可除外的魔法·陷阱卡。
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.rmfilter),tp,0,LOCATION_GRAVE,1,nil)
		-- 询问玩家是否选择发动追加的除外效果。
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否除外？"
		-- 中断当前效果处理，使后续的除外处理不与破坏同时进行。
		Duel.BreakEffect()
		-- 获取对方墓地中所有不受「王家长眠之谷」影响且可除外的魔法·陷阱卡。
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.rmfilter),tp,0,LOCATION_GRAVE,nil)
		if g:GetCount()>0 then
			-- 将对方墓地的魔法·陷阱卡全部表侧表示除外。
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
end
-- 免疫效果的适用条件判定：这张卡是否在额外怪兽区域存在。
function s.efcon(e)
	return e:GetHandler():GetSequence()>4
end
-- 免疫效果的过滤函数：不受自身以外的其他怪兽发动的效果影响。
function s.efilter(e,te)
	return te:IsActiveType(TYPE_MONSTER) and te:GetOwner()~=e:GetOwner()
end
