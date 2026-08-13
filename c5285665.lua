--E・HERO バブルマン・ネオ
-- 效果：
-- 这张卡不能通常召唤。把自己场上存在的「元素英雄 水泡侠」和手卡的「突然变异」送去墓地的场合才能特殊召唤。只要这张卡在场上表侧表示存在，卡名当作「元素英雄 水泡侠」使用。和这张卡进行战斗的怪兽在伤害步骤结束时破坏。
function c5285665.initial_effect(c)
	-- 记录这张卡上记载着「元素英雄 水泡侠」和「突然变异」的卡名，供相关融合等效果识别其关联卡名。
	aux.AddCodeList(c,79979666,46411259)
	c:EnableReviveLimit()
	-- “这张卡不能通常召唤。”
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- “把自己场上存在的「元素英雄 水泡侠」和手卡的「突然变异」送去墓地的场合才能特殊召唤。”
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c5285665.spcon)
	e2:SetTarget(c5285665.sptg)
	e2:SetOperation(c5285665.spop)
	c:RegisterEffect(e2)
	-- 令这张卡在怪兽区表侧表示期间，其卡名被当作「元素英雄 水泡侠」使用，对应效果原文“只要这张卡在场上表侧表示存在，卡名当作「元素英雄 水泡侠」使用”。
	aux.EnableChangeCode(c,79979666)
	-- “和这张卡进行战斗的怪兽在伤害步骤结束时破坏。”
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(5285665,0))  --"破坏"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_DAMAGE_STEP_END)
	-- 设置战斗破坏触发类效果的发动条件：仅在伤害步骤结束时，若这张卡仍处于未离场或带有战斗破坏状态时，条件成立。
	e4:SetCondition(aux.dsercon)
	e4:SetTarget(c5285665.destg)
	e4:SetOperation(c5285665.desop)
	c:RegisterEffect(e4)
end
-- 定义素材筛选函数：卡名是「元素英雄 水泡侠」或「突然变异」，且可以作为cost送去墓地。
function c5285665.spfilter(c)
	return c:IsCode(79979666,46411259) and c:IsAbleToGraveAsCost()
end
-- 定义“场上表侧表示的水泡侠”素材筛选：要求是己方场上的表侧表示的「元素英雄 水泡侠」，并且把它移走后己方的怪兽区仍有空格。
function c5285665.spfilter1(c,tp)
	-- 具体判定：该卡必须是「元素英雄 水泡侠」，表侧表示且在怪兽区，同时以此卡为素材送墓后己方仍有至少1个怪兽区空格用来特殊召唤新水泡侠。
	return c:IsCode(79979666) and c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and Duel.GetMZoneCount(tp,c)>0
end
-- 定义“手卡的突然变异”素材筛选：要求是手牌中的「突然变异」。
function c5285665.spfilter2(c)
	return c:IsCode(46411259) and c:IsLocation(LOCATION_HAND)
end
-- 特殊召唤手续的条件函数：从己方手卡和怪兽区中，检查是否能选出1只场上表侧表示的「元素英雄 水泡侠」和1张手卡的「突然变异」作为素材，并保证腾出怪兽区空格。
function c5285665.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取己方手卡和怪兽区中所有可以作为素材的「元素英雄 水泡侠」和「突然变异」的候选组。
	local g=Duel.GetMatchingGroup(c5285665.spfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
	-- 检查候选组中是否存在满足组合条件的2张卡：一张是场上表侧表示的水泡侠且腾出空格，另一张是手卡的突然变异，顺序不限。
	return g:CheckSubGroup(aux.gffcheck,2,2,c5285665.spfilter1,tp,c5285665.spfilter2,nil)
end
-- 特殊召唤手续的选择阶段：让玩家从候选素材中选择要送去墓地的2张卡，选中的组保存到效果的LabelObject中，若未选择则特殊召唤不进行。
function c5285665.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取候选素材组：己方手卡和怪兽区中所有可作为素材的水泡侠和突然变异。
	local g=Duel.GetMatchingGroup(c5285665.spfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
	-- 向玩家显示选择提示：‘请选择要送去墓地的卡’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择一组2张素材，需要满足一张是场上表侧表示的水泡侠且腾出空格、另一张是手卡的突然变异；选择成功则保留该组。
	local sg=g:SelectSubGroup(tp,aux.gffcheck,true,2,2,c5285665.spfilter1,tp,c5285665.spfilter2,nil)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤手续的处理：将之前选好的素材组送去墓地，完成这次特殊召唤所需的送墓动作。
function c5285665.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 把选中的素材卡送去墓地，原因是本次特殊召唤（作为召唤手续）。
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 破坏效果的目标判定：取得与这张卡进行战斗的怪兽，若该怪兽仍与本次战斗相关，则将作为破坏目标。
function c5285665.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	if chk==0 then return bc and bc:IsRelateToBattle() end
	-- 登记本次连锁的破坏操作信息：将战斗对象怪兽作为将被破坏的卡片，数量为1，便于其他卡进行应对（如星尘龙）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,bc,1,0,0)
end
-- 破坏效果处理：若战斗对象怪兽仍与本次战斗相关，则将其破坏。
function c5285665.desop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	if bc:IsRelateToBattle() then
		-- 以效果破坏战斗对象怪兽。
		Duel.Destroy(bc,REASON_EFFECT)
	end
end
