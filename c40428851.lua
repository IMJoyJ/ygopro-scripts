--戦華の徳－劉玄
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：只要自己场上有其他的「战华」怪兽存在，对方不能选择这张卡作为攻击对象。
-- ②：对方场上的怪兽数量比自己场上的怪兽多的场合，从自己的手卡·场上把1张卡送去墓地才能发动。从卡组把「战华之德-刘玄」以外的1只「战华」怪兽特殊召唤。
-- ③：这张卡以外的自己的「战华」怪兽进行战斗的攻击宣言时才能发动。自己从卡组抽1张。
function c40428851.initial_effect(c)
	-- ①：只要自己场上有其他的「战华」怪兽存在，对方不能选择这张卡作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetCondition(c40428851.atcon)
	-- 将“不能成为攻击对象”效果的值设为aux.imval1，使不免疫此效果的卡不能选择这张卡为攻击对象。
	e1:SetValue(aux.imval1)
	c:RegisterEffect(e1)
	-- ②：对方场上的怪兽数量比自己场上的怪兽多的场合，从自己的手卡·场上把1张卡送去墓地才能发动。从卡组把「战华之德-刘玄」以外的1只「战华」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(40428851,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,40428851)
	e2:SetCondition(c40428851.spcon)
	e2:SetCost(c40428851.spcost)
	e2:SetTarget(c40428851.sptg)
	e2:SetOperation(c40428851.spop)
	c:RegisterEffect(e2)
	-- ③：这张卡以外的自己的「战华」怪兽进行战斗的攻击宣言时才能发动。自己从卡组抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(40428851,1))
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,40428852)
	e3:SetCondition(c40428851.drcon)
	e3:SetTarget(c40428851.drtg)
	e3:SetOperation(c40428851.drop)
	c:RegisterEffect(e3)
end
-- 定义筛选函数：用于判断卡是否为表侧表示且属于「战华」系列。
function c40428851.atfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x137)
end
-- 定义①效果的生效条件：自己场上有其他表侧表示的「战华」怪兽存在。
function c40428851.atcon(e)
	-- 检查自己场上是否存在1张满足atfilter且不是效果持有者自身的「战华」怪兽，即存在其他「战华」怪兽。
	return Duel.IsExistingMatchingCard(c40428851.atfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
-- 定义②特殊召唤的筛选函数：卡是「战华」怪兽、不是“战华之德-刘玄”本身、且可以被tp特殊召唤。
function c40428851.spfilter(c,e,tp)
	return c:IsSetCard(0x137) and c:IsType(TYPE_MONSTER) and not c:IsCode(40428851) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义②效果的发动条件：对方场上的怪兽数量比自己场上的怪兽数量多。
function c40428851.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 比较自己和对方场上怪兽数量，若自己场上的怪兽数小于对方场上的怪兽数则条件成立。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)<Duel.GetFieldGroupCount(1-tp,LOCATION_MZONE,0)
end
-- 定义②代价的筛选函数：这张卡送去墓地后自己场上仍有空余怪兽区，且该卡可以作为代价送去墓地。
function c40428851.costfilter(c,tp)
	-- 判断把c送去墓地后自己场上是否有空余怪兽区，且c可以作为代价送去墓地。
	return Duel.GetMZoneCount(tp,c)>0 and c:IsAbleToGraveAsCost()
end
-- 定义②效果的代价：从自己的手卡·场上选择1张卡送去墓地。
function c40428851.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测阶段确认存在1张可从手卡·场上送去墓地作为代价的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c40428851.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil,tp) end
	-- 显示“请选择要送去墓地的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己的手卡·场上选择1张满足costfilter的卡作为发动代价。
	local g=Duel.SelectMatchingCard(tp,c40428851.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil,tp)
	-- 将选择的卡送去墓地，作为代价处理（REASON_COST）。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 定义②效果的目标：确认卡组存在可特殊召唤的「战华」怪兽，并设置特殊召唤的操作信息。
function c40428851.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 目标检测阶段确认卡组存在满足spfilter的「战华」怪兽，即效果可以发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c40428851.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：效果处理时从卡组特殊召唤1只怪兽（对象不取，数量1，卡组）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 定义②效果处理时的操作：从卡组选择1只符合条件的「战华」怪兽特殊召唤。
function c40428851.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理前检查自己场上是否有怪兽区空位，无空位则不进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只满足spfilter的「战华」怪兽。
	local g=Duel.SelectMatchingCard(tp,c40428851.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义③效果的发动条件：本次攻击宣言中，存在这只卡以外的我方表侧表示「战华」怪兽（可能是攻击者或被攻击对象）。
function c40428851.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取进行攻击宣言的攻击怪兽。
	local ac=Duel.GetAttacker()
	-- 获取被攻击的怪兽（可能为nil），用于确定我方「战华」怪兽是否参与战斗。
	local tc=Duel.GetAttackTarget()
	if not ac:IsControler(tp) then ac,tc=tc,ac end
	return ac and ac:IsControler(tp) and ac:IsFaceup() and ac:IsSetCard(0x137) and ac~=c
end
-- 定义③效果的目标：确认自己可以抽卡，并设置抽卡的玩家和数量。
function c40428851.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 目标检测阶段确认自己当前可以抽取1张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将连锁的对象玩家设为tp自己，表示由自己抽卡。
	Duel.SetTargetPlayer(tp)
	-- 将连锁的对象参数设为1，表示抽卡数量为1。
	Duel.SetTargetParam(1)
	-- 设置操作信息：效果处理时进行抽卡（玩家tp，数量1）。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 定义③效果处理时的操作：根据连锁中保存的玩家和数量执行抽卡。
function c40428851.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取抽卡玩家和抽卡数量。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p抽取d张卡，作为效果处理（REASON_EFFECT）。
	Duel.Draw(p,d,REASON_EFFECT)
end
