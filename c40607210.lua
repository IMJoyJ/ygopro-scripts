--ヴァンパイア・グレイス
-- 效果：
-- 这张卡在墓地存在，不死族怪兽的效果让自己场上有5星以上的不死族怪兽特殊召唤时，支付2000基本分才能发动。这张卡从墓地特殊召唤。「吸血鬼·格蕾丝」的这个效果1回合只能使用1次。此外，1回合1次，宣言卡的种类（怪兽·魔法·陷阱）才能发动。对方把宣言的种类的1张卡从卡组送去墓地。
function c40607210.initial_effect(c)
	-- 这张卡在墓地存在，不死族怪兽的效果让自己场上有5星以上的不死族怪兽特殊召唤时，支付2000基本分才能发动。这张卡从墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40607210,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,40607210)
	e1:SetCondition(c40607210.condition)
	e1:SetCost(c40607210.cost)
	e1:SetTarget(c40607210.target)
	e1:SetOperation(c40607210.operation)
	c:RegisterEffect(e1)
	-- 此外，1回合1次，宣言卡的种类（怪兽·魔法·陷阱）才能发动。对方把宣言的种类的1张卡从卡组送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(40607210,1))  --"卡组送墓"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c40607210.tgtg)
	e2:SetOperation(c40607210.tgop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断场上是否有满足条件的不死族怪兽（5星以上且为不死族）
function c40607210.cfilter(c,tp)
	local typ,race=c:GetSpecialSummonInfo(SUMMON_INFO_TYPE,SUMMON_INFO_RACE)
	return c:IsLevelAbove(5) and c:IsRace(RACE_ZOMBIE) and c:IsControler(tp)
		and typ&TYPE_MONSTER~=0 and race&RACE_ZOMBIE~=0
end
-- 判断是否有满足条件的不死族怪兽被特殊召唤
function c40607210.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c40607210.cfilter,1,nil,tp)
end
-- 检查玩家是否能支付2000基本分
function c40607210.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付2000基本分
	if chk==0 then return Duel.CheckLPCost(tp,2000) end
	-- 让玩家支付2000基本分
	Duel.PayLPCost(tp,2000)
end
-- 判断是否可以将此卡特殊召唤
function c40607210.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家场上是否有足够的特殊召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作
function c40607210.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 设置卡组送墓效果的处理信息
function c40607210.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 提示玩家选择卡的种类
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)  --"请选择一个种类"
	-- 让玩家宣言一个卡片类型（怪兽·魔法·陷阱）
	local op=Duel.AnnounceType(tp)
	e:SetLabel(op)
	-- 设置送去墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_DECK)
end
-- 过滤函数，用于筛选指定类型的卡
function c40607210.tgfilter(c,ty)
	return c:IsType(ty) and c:IsAbleToGrave()
end
-- 根据宣言的类型选择对方卡组中的一张卡
function c40607210.tgop(e,tp,eg,ep,ev,re,r,rp)
	local g=nil
	-- 提示对方选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 如果宣言的是怪兽类型，则选择对方卡组中的一张怪兽卡
	if e:GetLabel()==0 then g=Duel.SelectMatchingCard(1-tp,c40607210.tgfilter,1-tp,LOCATION_DECK,0,1,1,nil,TYPE_MONSTER)
	-- 如果宣言的是魔法类型，则选择对方卡组中的一张魔法卡
	elseif e:GetLabel()==1 then g=Duel.SelectMatchingCard(1-tp,c40607210.tgfilter,1-tp,LOCATION_DECK,0,1,1,nil,TYPE_SPELL)
	-- 如果宣言的是陷阱类型，则选择对方卡组中的一张陷阱卡
	else g=Duel.SelectMatchingCard(1-tp,c40607210.tgfilter,1-tp,LOCATION_DECK,0,1,1,nil,TYPE_TRAP) end
	if g:GetCount()~=0 then
		-- 将选中的卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
