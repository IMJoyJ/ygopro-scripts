--魔導獣 ガルーダ
-- 效果：
-- ←4 【灵摆】 4→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：另一边的自己的灵摆区域没有卡存在的场合，以这张卡以外的场上1张魔法·陷阱卡为对象才能发动。那张卡和这张卡破坏。
-- 【怪兽效果】
-- 这个卡名的①的怪兽效果1回合只能使用1次。
-- ①：对方对怪兽的召唤·特殊召唤成功时，把自己场上3个魔力指示物取除才能发动。这张卡从手卡特殊召唤。那之后，对方召唤·特殊召唤的那些怪兽回到持有者手卡。
-- ②：只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物。
function c28570310.initial_effect(c)
	-- 为这张卡添加灵摆怪兽属性，使其可以在灵摆区域发动并支持灵摆召唤
	aux.EnablePendulumAttribute(c)
	c:EnableCounterPermit(0x1)
	-- 这个卡名的灵摆效果1回合只能使用1次。①：另一边的自己的灵摆区域没有卡存在的场合，以这张卡以外的场上1张魔法·陷阱卡为对象才能发动。那张卡和这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28570310,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,28570310)
	e1:SetCondition(c28570310.descon)
	e1:SetTarget(c28570310.destg)
	e1:SetOperation(c28570310.desop)
	c:RegisterEffect(e1)
	-- 只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动（的辅助效果：在连锁发生时记录这张卡在场上存在）
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	-- 效果发动时用chainreg记录这张卡在场上存在，作为后续放置魔力指示物的前提判定
	e2:SetOperation(aux.chainreg)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetOperation(c28570310.acop)
	c:RegisterEffect(e3)
	-- 这个卡名的①的怪兽效果1回合只能使用1次。①：对方对怪兽的召唤·特殊召唤成功时，把自己场上3个魔力指示物取除才能发动。这张卡从手卡特殊召唤。那之后，对方召唤·特殊召唤的那些怪兽回到持有者手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(28570310,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetRange(LOCATION_HAND)
	e4:SetCountLimit(1,28570311)
	e4:SetCondition(c28570310.spcon)
	e4:SetCost(c28570310.spcost)
	e4:SetTarget(c28570310.sptg)
	e4:SetOperation(c28570310.spop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e5)
end
c28570310.mentioned_counter={
	[0x1]=true,
}
-- 灵摆效果发动条件的判定函数：确认另一边的自己的灵摆区域没有卡存在
function c28570310.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己灵摆区域除这张卡以外不存在其他卡，即另一边的灵摆区域没有卡存在
	return not Duel.IsExistingMatchingCard(nil,tp,LOCATION_PZONE,0,1,e:GetHandler())
end
-- 取对象的目标函数：确认场上存在这张卡以外的可以成为效果对象的魔法·陷阱卡，且这张卡可以破坏
function c28570310.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc~=c and chkc:IsType(TYPE_SPELL+TYPE_TRAP) end
	if chk==0 then return c:IsDestructable()
		-- 检查双方场上是否存在至少1张这张卡以外的可以作为效果对象的魔法·陷阱卡
		and Duel.IsExistingTarget(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c,TYPE_SPELL+TYPE_TRAP) end
	-- 向玩家提示「请选择要破坏的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择场上1张这张卡以外的魔法·陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c,TYPE_SPELL+TYPE_TRAP)
	g:AddCard(c)
	-- 设置连锁的操作信息：确定要破坏的卡为对象卡和这张卡本身，数量为卡数
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：这张卡和对象卡都与效果关联的场合，将两张卡一起破坏
function c28570310.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁的对象卡（发动时选择的魔法·陷阱卡）
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		local g=Group.FromCards(c,tc)
		-- 以效果原因破坏这张卡和对象卡（那张卡和这张卡破坏）
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 效果处理：这张卡在场上存在且该连锁是魔法卡发动的场合，给这张卡放置1个魔力指示物
function c28570310.acop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- 过滤函数：判断该怪兽是否是由指定玩家召唤·特殊召唤的
function c28570310.cfilter(c,tp)
	return c:IsSummonPlayer(tp)
end
-- 发动条件：确认这组召唤·特殊召唤的怪兽中存在由对方召唤·特殊召唤的怪兽
function c28570310.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c28570310.cfilter,1,nil,1-tp)
end
-- 发动代价：检查并把自己场上3个魔力指示物取除
function c28570310.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可以作为代价取除的3个魔力指示物
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x1,3,REASON_COST) end
	-- 把自己场上3个魔力指示物取除作为发动代价
	Duel.RemoveCounter(tp,1,0,0x1,3,REASON_COST)
end
-- 目标函数：确认自己怪兽区域有空位、这张卡可以从手卡特殊召唤，且对方召唤·特殊召唤的怪兽中有可以回到手卡的卡
function c28570310.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=eg:Filter(c28570310.cfilter,nil,1-tp):Filter(Card.IsAbleToHand,nil)
	-- 检查自己主要怪兽区域是否存在可用的空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and g:GetCount()>0 end
	-- 把召唤·特殊召唤的那组怪兽设为当前连锁的对象
	Duel.SetTargetCard(eg)
	-- 设置操作信息：确定要把这张卡从手卡特殊召唤1张
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	-- 设置操作信息：确定要把对方召唤·特殊召唤且可以回手卡的怪兽回到手卡，数量为其卡数
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理：这张卡从手卡特殊召唤成功的场合，把对方召唤·特殊召唤的那些怪兽回到持有者手卡
function c28570310.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡与效果关联并将其从手卡表侧表示特殊召唤，成功才继续处理
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local g=eg:Filter(c28570310.cfilter,nil,1-tp):Filter(Card.IsRelateToEffect,nil,e)
		if g:GetCount()>0 then
			-- 中断当前效果处理，使之后的回手卡处理视为不同时处理
			Duel.BreakEffect()
			-- 把那些怪兽以效果原因回到持有者手卡
			Duel.SendtoHand(g,nil,REASON_EFFECT)
		end
	end
end
