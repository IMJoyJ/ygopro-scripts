--幽獄の時計都市－ダーク・シティ
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡发动的回合的自己主要阶段才能发动。把1只「命运英雄」怪兽或者1张有那卡名记述的卡从卡组加入手卡。
-- ②：每次自己把8星以上的「命运英雄」怪兽特殊召唤发动。自己场上的全部战士族怪兽的攻击力上升300。
-- ③：这张卡被破坏的场合才能发动。从卡组把1只「命运英雄」怪兽当作「幽狱之时计塔」的效果作特殊召唤。
local s,id,o=GetID()
-- 初始化这张卡的全部效果：注册「幽狱之时计塔」的记述卡名，并依次注册场地魔法卡的发动效果（e1）、①的检索起动效果（e2）、②的攻击力上升诱发必发效果（e3）、③被破坏时特殊召唤的诱发选发效果（e4）
function s.initial_effect(c)
	-- 在这张卡上记录其效果文本中记述了「幽狱之时计塔」（卡号75041269）这一卡名
	aux.AddCodeList(c,75041269)
	-- （卡片发动本身，对应场地魔法卡的发动规则，无效果序号）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.reg)
	c:RegisterEffect(e1)
	-- ①：这张卡发动的回合的自己主要阶段才能发动。把1只「命运英雄」怪兽或者1张有那卡名记述的卡从卡组加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"检索"
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ②：每次自己把8星以上的「命运英雄」怪兽特殊召唤发动。自己场上的全部战士族怪兽的攻击力上升300。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"攻击力上升"
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCondition(s.atkcon)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
	-- ③：这张卡被破坏的场合才能发动。从卡组把1只「命运英雄」怪兽当作「幽狱之时计塔」的效果作特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,id+o)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
-- 发动时的代价处理：给这张卡注册持续到回合结束的标记效果，用于标记这张卡是本回合发动的（①效果的发动条件用）
function s.reg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- ①效果的发动条件：确认这张卡带有本回合发动的标记，即这张卡发动的回合的自己主要阶段才能发动
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)~=0
end
-- 检索过滤函数：判断卡片是否为可以加入手卡的「命运英雄」怪兽，或效果文本中记述了「命运英雄」系列怪兽卡名且可以加入手卡的卡
function s.thfilter(c)
	-- 这张卡是「命运英雄」怪兽，或者效果文本中记述了「命运英雄」系列怪兽的卡名，并且可以加入手卡
	return (c:IsSetCard(0xc008) and c:IsType(TYPE_MONSTER) or aux.IsSetNameMonsterListed(c,0xc008)) and c:IsAbleToHand()
end
-- ①效果的目标设定：确认卡组存在可检索的卡，并设置「从卡组把1张卡加入手卡」的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动可行性检查：自己卡组存在至少1张满足检索条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：预计从自己的卡组把1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理：让玩家从卡组选择1张满足条件的卡加入手卡，并向对方展示
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示「请选择要加入手牌的卡」的选择提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己的卡组选择1张满足检索条件的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 把选择的卡因效果加入持有者手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 把加入手卡的卡向对方玩家展示确认
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 攻击力上升效果的触发判定过滤函数：判断特殊召唤的怪兽是否为自己召唤的表侧表示8星以上的「命运英雄」怪兽
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsLevelAbove(8) and c:IsSetCard(0xc008) and c:IsSummonPlayer(tp)
end
-- ②效果的触发条件：本次特殊召唤成功的怪兽中存在自己召唤的8星以上的「命运英雄」怪兽
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 攻击力上升对象的过滤函数：判断怪兽是否为表侧表示的战士族怪兽
function s.atkfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
-- ②效果的处理：取出自己场上全部表侧表示的战士族怪兽，逐只赋予攻击力上升300的永续效果
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己怪兽区域全部表侧表示的战士族怪兽
	local g=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_MZONE,0,nil)
	-- 遍历这组战士族怪兽，逐只进行处理
	for tc in aux.Next(g) do
		-- 自己场上的全部战士族怪兽的攻击力上升300。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 特殊召唤过滤函数：判断卡片是否为可以特殊召唤的「命运英雄」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xc008) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 生成一个把这张卡的卡名当作「幽狱之时计塔」（卡号75041269）使用的效果并注册，返回该效果以便之后重置
function s.rneffect(c)
	-- 从卡组把1只「命运英雄」怪兽当作「幽狱之时计塔」的效果作特殊召唤。
	local e=Effect.CreateEffect(c)
	e:SetType(EFFECT_TYPE_SINGLE)
	e:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e:SetCode(EFFECT_CHANGE_CODE)
	e:SetValue(75041269)
	e:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e)
	return e
end
-- ③效果的目标设定：临时把这张卡的卡名当作「幽狱之时计塔」，检查自己怪兽区域有空位且卡组存在可特殊召唤的「命运英雄」怪兽，随后重置该改名效果并返回检查结果，最后设置特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local e1=s.rneffect(c)
		-- 自己的怪兽区域存在可用的空格
		local res=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 并且卡组存在至少1只可以特殊召唤的「命运英雄」怪兽
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
		e1:Reset()
		return res
	end
	-- 设置操作信息：预计从自己的卡组把1只怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ③效果的处理：怪兽区域没有空位则中断；临时把这张卡的卡名当作「幽狱之时计塔」，让玩家从卡组选择1只「命运英雄」怪兽表侧表示特殊召唤，处理完毕后重置改名效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 自己怪兽区域没有可用空位则中断处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	local e1=s.rneffect(c)
	-- 向玩家显示「请选择要特殊召唤的卡」的选择提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己的卡组选择1只可以特殊召唤的「命运英雄」怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 把选择的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
	e1:Reset()
end
