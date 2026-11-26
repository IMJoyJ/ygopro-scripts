--ブリーチヴァレル・ドラゴン
-- 效果：
-- 包含「弹丸」怪兽的龙族·暗属性怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡连接召唤的场合才能发动。从卡组把1张「枪管」魔法·陷阱卡加入手卡。
-- ②：自己·对方回合，以自己场上1只暗属性怪兽为对象才能发动。那只怪兽的攻击力上升500。作为对象的怪兽不存在的场合，可以作为代替从卡组把1只「弹丸」怪兽守备表示特殊召唤。
local s,id,o=GetID()
-- 初始化「后膛枪管龙」(90011273)：设置连接召唤手续与苏生限制，并注册①连接召唤成功检索「枪管」魔陷与②双方回合加攻500或对象消失时替代特召「弹丸」怪兽的效果
function s.initial_effect(c)
	-- 设置连接召唤手续：需包含「弹丸」怪兽(s.lcheck)的龙族·暗属性怪兽(s.mfilter)恰好2只
	aux.AddLinkProcedure(c,s.mfilter,2,2,s.lcheck)
	c:EnableReviveLimit()
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡连接召唤的场合才能发动。从卡组把1张「枪管」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索效果"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：自己·对方回合，以自己场上1只暗属性怪兽为对象才能发动。那只怪兽的攻击力上升500。作为对象的怪兽不存在的场合，可以作为代替从卡组把1只「弹丸」怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"上升攻击力"
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetHintTiming(TIMING_DAMAGE_STEP+TIMING_END_PHASE)
	e2:SetCountLimit(1,id+o)
	-- 设置效果②的Condition函数为aux.dscon（允许在伤害步骤的伤害计算前发动）
	e2:SetCondition(aux.dscon)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
-- 连接素材单卡过滤函数：筛选暗属性且为龙族（或带有将其当作龙族连接素材使用的效果77189532）的怪兽
function s.mfilter(c)
	return c:IsLinkAttribute(ATTRIBUTE_DARK) and (c:IsLinkRace(RACE_DRAGON) or c:IsHasEffect(77189532))
end
-- 连接素材整体检查函数：确保所选2只素材中至少包含1只「弹丸」(0x102)怪兽
function s.lcheck(g,lc)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x102)
end
-- 效果①的Condition函数：检查这张卡是否是通过连接召唤方式出场的
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 过滤函数：筛选卡组中属于「枪管」(0x10f)字段且可加入手卡的魔法卡或陷阱卡
function s.thfilter(c)
	return c:IsSetCard(0x10f) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果①的Target函数：检测卡组中存在可检索的「枪管」魔法·陷阱卡，并设置从卡组把1张卡加入手卡的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检测时确认己方卡组中存在至少1张可加入手卡的「枪管」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置从己方卡组把1张卡加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的Operation函数：从己方卡组选择1张「枪管」魔法·陷阱卡加入手卡并向对方确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向己方玩家发送选择要加入手卡的「枪管」魔法·陷阱卡提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从己方卡组中选择1张可加入手卡的「枪管」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 以效果将选中的「枪管」魔法·陷阱卡加入持有者（己方）手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家公开确认加入手卡的「枪管」魔法·陷阱卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤函数：筛选场上表侧表示的暗属性怪兽
function s.atkfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK)
end
-- 效果②的Target函数：验证续指对象是否为自己场上的表侧暗属性怪兽，并在发动时选择1只自己场上的暗属性怪兽为对象
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup()
		and s.atkfilter(chkc) and chkc:IsControler(tp) end
	-- 发动检测时确认己方怪兽区存在至少1只可作为对象的表侧暗属性怪兽
	if chk==0 then return Duel.IsExistingTarget(s.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向己方玩家发送选择表侧表示暗属性怪兽的提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从己方怪兽区选择1只表侧表示的暗属性怪兽作为效果对象
	Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 过滤函数：筛选卡组中属于「弹丸」(0x102)字段且可表侧守备表示特殊召唤的怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x102) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果②的Operation函数：若对象怪兽仍在场（表侧），使其攻击力上升500；若对象怪兽已不在场，可选择从卡组表侧守备表示特殊召唤1只「弹丸」怪兽
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时指定为对象的己方暗属性怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		if tc:IsFaceup() then
			-- 那只怪兽的攻击力上升500。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(500)
			tc:RegisterEffect(e1)
		end
	-- 当对象怪兽已不再与连锁关联（不存在）时，检查己方主要怪兽区是否仍有可用空位
	elseif Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且检查己方卡组中是否存在至少1只可表侧守备表示特殊召唤的「弹丸」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
		-- 询问己方玩家是否要作为代替从卡组特殊召唤1只「弹丸」怪兽
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤？"
		-- 向己方玩家发送选择要特殊召唤的「弹丸」怪兽提示
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从己方卡组中选择1只可守备表示特殊召唤的「弹丸」怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的「弹丸」怪兽以表侧守备表示特殊召唤到己方场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
end
