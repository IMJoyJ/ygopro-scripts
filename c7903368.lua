--水晶ドクロ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡召唤·反转召唤·特殊召唤成功的场合发动。自己受到1000伤害。那之后，这张卡变成守备表示。
-- ②：自己没有受到效果伤害的回合的结束阶段才能发动。从卡组选1只攻击力0的岩石族怪兽加入手卡或特殊召唤。
local s,id,o=GetID()
-- 初始化函数，注册卡片的所有效果，并设置全局监听器来记录玩家是否受到效果伤害
function s.initial_effect(c)
	-- ①：这张卡召唤·反转召唤·特殊召唤成功的场合发动。自己受到1000伤害。那之后，这张卡变成守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(s.postg)
	e1:SetOperation(s.posop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ②：自己没有受到效果伤害的回合的结束阶段才能发动。从卡组选1只攻击力0的岩石族怪兽加入手卡或特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.thcon)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
	if not s.global_check then
		s.global_check=true
		s[0]=0
		s[1]=0
		-- 自己没有受到效果伤害的回合
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DAMAGE)
		ge1:SetOperation(s.regop)
		-- 注册全局效果，用于监听并记录玩家受到的伤害事件
		Duel.RegisterEffect(ge1,0)
		-- ①：这张卡召唤·反转召唤·特殊召唤成功的场合发动。自己受到1000伤害。那之后，这张卡变成守备表示。②：自己没有受到效果伤害的回合的结束阶段才能发动。从卡组选1只攻击力0的岩石族怪兽加入手卡或特殊召唤。
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge2:SetOperation(s.resetop)
		-- 注册全局效果，用于在每个回合开始时重置玩家受到效果伤害的记录
		Duel.RegisterEffect(ge2,0)
	end
end
-- 伤害事件触发时的全局处理函数，若受到的是效果伤害，则将对应玩家的受伤害标记设为1
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if r&REASON_EFFECT>0 then s[ep]=1 end
end
-- 回合开始时的全局重置函数，将双方玩家的受效果伤害标记重置为0
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	s[0]=0
	s[1]=0
end
-- 效果①的发动准备（Target）函数，设置效果分类为伤害，并注册伤害操作信息
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前处理的连锁的操作信息，表明该效果会给与玩家1000点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,1000)
end
-- 效果①的效果处理（Operation）函数，给与玩家1000点伤害，若伤害成功，则将此卡变为守备表示
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 给与玩家1000点效果伤害，若实际受到的伤害小于等于0，则不处理后续效果
	if Duel.Damage(tp,1000,REASON_EFFECT)<=0 then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsAttackPos() then
		-- 中断当前效果处理，使后续的改变表示形式处理与前一步的伤害处理不视为同时进行
		Duel.BreakEffect()
		-- 将这张卡转为表侧守备表示
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
-- 效果②的发动条件函数，检查当前回合自己是否没有受到过效果伤害
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return s[tp]==0
end
-- 过滤函数，筛选卡组中攻击力为0的岩石族怪兽，且该怪兽必须满足能加入手卡或能特殊召唤的条件
function s.sfilter(c,e,tp)
	return c:IsRace(RACE_ROCK) and c:IsAttack(0) and (c:IsAbleToHand()
		-- 检查自己场上是否有空余的怪兽区域，且该怪兽是否可以被特殊召唤
		or (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
-- 效果②的发动准备（Target）函数，检查卡组中是否存在满足条件的怪兽
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查卡组中是否存在至少1只满足条件的攻击力0岩石族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
end
-- 效果②的效果处理（Operation）函数，从卡组选择1只满足条件的怪兽，并让玩家选择将其加入手卡或特殊召唤
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息，提示选择要操作的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 让玩家从卡组中选择1只满足过滤条件的怪兽
	local tc=Duel.SelectMatchingCard(tp,s.sfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if tc then
		local th=tc:IsAbleToHand()
		-- 检查当前是否满足将该怪兽特殊召唤的条件（有空余怪兽区域且该怪兽可特召）
		local sp=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		local op=0
		-- 如果该怪兽既能加入手卡也能特殊召唤，则让玩家选择“加入手卡”或“特殊召唤”
		if th and sp then op=Duel.SelectOption(tp,1190,1152)
		elseif th then op=0
		else op=1 end
		if op==0 then
			-- 将选中的怪兽加入玩家手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手卡的卡片
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 将选中的怪兽以表侧表示特殊召唤到自己的场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
