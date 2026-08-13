--アーティファクト－ベガルタ
-- 效果：
-- 这张卡可以当作魔法卡使用从手卡到魔法与陷阱卡区域盖放。魔法与陷阱卡区域盖放的这张卡在对方回合被破坏送去墓地时，这张卡特殊召唤。对方回合中这张卡特殊召唤成功的场合，选自己场上盖放的最多2张卡破坏。「古遗物-微怒剑」的这个效果1回合只能使用1次。
function c12697630.initial_effect(c)
	-- 这张卡可以当作魔法卡使用从手卡到魔法与陷阱卡区域盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MONSTER_SSET)
	e1:SetValue(TYPE_SPELL)
	c:RegisterEffect(e1)
	-- 魔法与陷阱卡区域盖放的这张卡在对方回合被破坏送去墓地时，这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(12697630,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c12697630.spcon)
	e2:SetTarget(c12697630.sptg)
	e2:SetOperation(c12697630.spop)
	c:RegisterEffect(e2)
	-- 对方回合中这张卡特殊召唤成功的场合，选自己场上盖放的最多2张卡破坏。「古遗物-微怒剑」的这个效果1回合只能使用1次。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(12697630,1))  --"破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,12697630)
	e3:SetCondition(c12697630.descon)
	e3:SetTarget(c12697630.destg)
	e3:SetOperation(c12697630.desop)
	c:RegisterEffect(e3)
end
-- 特殊召唤效果的发动条件：判断这张卡在被破坏送去墓地之前处于我方魔法与陷阱卡区域的里侧表示状态，且被破坏时控制者为效果发动方，破坏原因为破坏，并且当前回合为对方回合。
function c12697630.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousPosition(POS_FACEDOWN)
		and c:IsPreviousControler(tp)
		-- 并且这张卡的破坏原因为破坏，且当前回合玩家不是其控制者，即满足“对方回合被破坏”的条件。
		and c:IsReason(REASON_DESTROY) and Duel.GetTurnPlayer()~=tp
end
-- 特殊召唤效果的发动时处理：该效果不取对象，直接确认可发动，并登记特殊召唤此卡的操作信息。
function c12697630.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向连锁处理登记本次操作包含特殊召唤分类，预定特殊召唤的对象为效果所属卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果处理：若此卡仍与发动效果相关联，则将其以表侧表示特殊召唤到其控制者的场上。
function c12697630.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到其控制者场上，sumtype为0，正常检查召唤条件与苏生限制。
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 破坏效果的发动条件：当前回合是这张卡控制者的对方回合，以此限定“对方回合中特殊召唤成功”的时机。
function c12697630.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家不是这张卡的控制者，即必须是对手回合。
	return Duel.GetTurnPlayer()~=tp
end
-- 筛选条件为里侧表示的卡，用于选择自己场上盖放的卡作为可破坏对象。
function c12697630.filter(c)
	return c:IsFacedown()
end
-- 破坏效果的目标函数：不取对象，效果发动时检查自己场上是否存在里侧表示的卡，若有则登记破坏操作信息，实际破坏数量在处理时选择1到2张。
function c12697630.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取自己场上所有里侧表示的卡，作为可能被破坏的候选集合（包含怪兽区和魔法与陷阱区的里侧卡）。
	local g=Duel.GetMatchingGroup(c12697630.filter,tp,LOCATION_ONFIELD,0,nil)
	if g:GetCount()>0 then
		-- 向连锁处理登记本次操作包含破坏分类，候选破坏对象为所有里侧表示的卡，预计处理数量为1。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
end
-- 破坏效果的实际处理：从自己场上所有里侧表示的卡中选择1到2张（若存在），将其破坏。
function c12697630.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有里侧表示的卡，作为破坏选择时的候选集合。
	local g=Duel.GetMatchingGroup(c12697630.filter,tp,LOCATION_ONFIELD,0,nil)
	if g:GetCount()>0 then
		-- 向当前玩家显示“请选择要破坏的卡”的提示，提示类型为选择卡牌。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local sg=g:Select(tp,1,2,nil)
		-- 将选择出的里侧表示卡以“效果”的原因破坏并送去墓地。
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
