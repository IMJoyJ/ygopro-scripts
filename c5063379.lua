--剣闘獣の闘技場－フラヴィス
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：丢弃1张手卡才能发动。从卡组把1只「剑斗兽」怪兽加入手卡。
-- ②：对方怪兽的攻击宣言时才能发动。从卡组把1只「剑斗兽」怪兽特殊召唤。这个效果特殊召唤的怪兽不会被战斗破坏。
-- ③：这个回合从自己卡组有「剑斗兽」怪兽特殊召唤的场合，结束阶段才能发动。从卡组把1张「剑斗」陷阱卡在自己场上盖放。
local s,id,o=GetID()
-- 注册场地魔法卡的发动效果，并注册①检索、②特殊召唤、③盖放三个效果，以及一个全局辅助效果用于记录本回合从卡组特殊召唤剑斗兽的情况。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：丢弃1张手卡才能发动。从卡组把1只「剑斗兽」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ②：对方怪兽的攻击宣言时才能发动。从卡组把1只「剑斗兽」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"卡组特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	-- ③：这个回合从自己卡组有「剑斗兽」怪兽特殊召唤的场合，结束阶段才能发动。从卡组把1张「剑斗」陷阱卡在自己场上盖放。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"卡组盖放"
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetCategory(CATEGORY_SSET)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,id+o*2)
	e4:SetCondition(s.setcon)
	e4:SetTarget(s.settg)
	e4:SetOperation(s.setop)
	c:RegisterEffect(e4)
	if not s.global_check then
		s.global_check=true
		-- 这个卡名的①②③的效果1回合各能使用1次。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(s.chk)
		-- 将全局监测效果注册到双方玩家，使其在每次特殊召唤成功时触发s.chk。
		Duel.RegisterEffect(ge1,0)
	end
end
-- s.chkfilter：判断怪兽是否属于玩家tp、是否从卡组特殊召唤、且为「剑斗兽」怪兽。
function s.chkfilter(c,tp)
	return c:GetOwner()==tp and c:IsSummonLocation(LOCATION_DECK) and c:IsSetCard(0x1019)
end
-- s.chk：遍历本次特殊召唤成功的怪兽，若存在从卡组特殊召唤的剑斗兽，则为对应玩家注册本回合标记，供③效果发动使用。
function s.chk(e,tp,eg,ep,ev,re,r,rp)
	for p=0,1 do
		local tc=eg:GetFirst()
		while tc do
			if s.chkfilter(tc,p) then
				-- 给玩家p注册本回合结束阶段重置的标记，表示该玩家本回合从卡组特殊召唤过「剑斗兽」怪兽。
				Duel.RegisterFlagEffect(p,id,RESET_PHASE+PHASE_END,0,1)
			end
			tc=eg:GetNext()
		end
	end
end
-- s.thcost：①效果的代价函数，确认并执行丢弃1张手卡。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价检测阶段，检查玩家手牌中是否有至少1张可以丢弃的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 处理丢弃1张手卡的代价，丢弃原因视为代价和丢弃。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- s.thfilter：筛选卡组中的「剑斗兽」怪兽且能够加入手卡。
function s.thfilter(c)
	return c:IsSetCard(0x1019) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- s.thtg：①效果的发动目标条件，若卡组存在符合条件的剑斗兽怪兽则可发动，并设置操作信息为从卡组加入手卡。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时确认卡组中存在1只以上符合条件的「剑斗兽」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次连锁的操作信息：将1张卡从卡组加入手卡（用于时点检测）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- s.thop：①效果处理，从卡组选择1只「剑斗兽」怪兽加入手卡，并让对方确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	-- 显示选择提示文本“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只满足s.thfilter的「剑斗兽」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- s.spcon：②效果的发动条件，攻击宣言的怪兽为对方怪兽。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断攻击怪兽的控制者不是自己。
	return Duel.GetAttacker():GetControler()~=tp
end
-- s.spfilter：筛选卡组中可被效果特殊召唤的「剑斗兽」怪兽。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1019) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- s.sptg：②效果的发动目标条件，自己场上存在可用怪兽区且卡组存在可特召的剑斗兽怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且卡组中存在符合条件的「剑斗兽」怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置本次连锁的操作信息：从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- s.spop：②效果处理，从卡组选择1只「剑斗兽」怪兽特殊召唤，并使其在这个回合内不会被战斗破坏。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理前检查：场地卡不在场上或与效果失去联系，或自己场上没有可用怪兽区时，效果不处理。
	if not e:GetHandler():IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示选择提示文本“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只满足s.spfilter的「剑斗兽」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		-- 这个效果特殊召唤的怪兽不会被战斗破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		g:GetFirst():RegisterEffect(e1)
	end
end
-- s.setcon：③效果的发动条件，本回合自己曾从卡组特殊召唤过「剑斗兽」怪兽。
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己是否存在对应的标记，即本回合是否从卡组特殊召唤过「剑斗兽」怪兽。
	return Duel.GetFlagEffect(tp,id)~=0
end
-- s.setfilter：筛选卡组中的「剑斗」字段陷阱卡且能够盖放。
function s.setfilter(c)
	return c:IsSetCard(0x19) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- s.settg：③效果的发动目标条件，卡组中存在「剑斗」陷阱卡即可发动。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时确认卡组中存在至少1张符合条件的「剑斗」陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- s.setop：③效果处理，从卡组选择1张「剑斗」陷阱卡盖放到自己场上。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示文本“请选择要盖放的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组选择1张满足s.setfilter的「剑斗」陷阱卡。
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的陷阱卡盖放到自己魔法与陷阱区域。
		Duel.SSet(tp,g:GetFirst())
	end
end
