--カプシー☆ヤミー
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：连接1怪兽或者2星同调怪兽在自己场上存在的场合，这张卡可以从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把「奶油蛋糕杯猫☆味美喵」以外的1张「味美喵」卡加入手卡。同调怪兽的效果特殊召唤的场合，作为代替让自己也能抽1张。
local s,id,o=GetID()
-- 初始化此卡的效果：注册①的手卡规则特殊召唤效果、②的召唤·特殊召唤时检索/抽卡诱发效果，以及用于判定“同调怪兽的效果特殊召唤”的辅助效果。
function s.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：连接1怪兽或者2星同调怪兽在自己场上存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把「奶油蛋糕杯猫☆味美喵」以外的1张「味美喵」卡加入手卡。同调怪兽的效果特殊召唤的场合，作为代替让自己也能抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索"
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- 同调怪兽的效果特殊召唤的场合，作为代替让自己也能抽1张。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetOperation(s.checkop)
	c:RegisterEffect(e4)
end
-- 定义“场上存在连接1或2星同调怪兽”的判定：怪兽为表侧表示，且是等级2的同调怪兽或连接1的连接怪兽。
function s.filter(c)
	return (c:IsLevel(2) and c:IsType(TYPE_SYNCHRO) or c:IsLink(1) and c:IsType(TYPE_LINK)) and c:IsFaceup()
end
-- ①的特殊召唤规则条件：自己主要怪兽区有空位，且自己场上有表侧表示的连接1怪兽或2星同调怪兽存在时，才能从手卡把这张卡特殊召唤（c==nil时表示规则手续本身的判定）。
function s.spcon(e,c)
	if c==nil then return true end
	-- 判定自己场上是否存在可用的主要怪兽区空格。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 判定自己场上是否存在满足s.filter的怪兽（连接1或2星同调的表侧怪兽）。
		and Duel.IsExistingMatchingCard(s.filter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 定义检索对象：持有「味美喵」字段、不是这张卡自身、且能够加入手卡的卡。
function s.thfilter(c)
	return c:IsSetCard(0x1ca) and not c:IsCode(id) and c:IsAbleToHand()
end
-- ②的发动合法性判定：满足“卡组有符合检索条件的卡”或“这张卡是被同调怪兽的效果特殊召唤的场合且可以抽1张”时，效果可以发动。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在符合检索条件的「味美喵」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 检查这张卡是否带上了“被同调怪兽效果特殊召唤”的标记，并且当前玩家可以抽1张卡；满足则也允许发动（可选择抽卡代替检索）。
		or e:GetHandler():GetFlagEffect(id)>0 and Duel.IsPlayerCanDraw(tp,1) end
	if e:GetHandler():GetFlagEffect(id)>0 then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
	-- 登记效果处理信息：本次操作包含从卡组加入手牌（CATEGORY_TOHAND），预计处理1张，由tp从卡组选择，供相关卡检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②的效果处理：若卡组有可检索对象且玩家未选择抽卡代替，则从卡组检索1张「味美喵」以外（含字段）的卡加入手牌；若本卡是同调怪兽效果特殊召唤且玩家选择抽卡，则抽1张。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断此时卡组是否存在符合条件的「味美喵」卡。
	local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	-- 判断是否可以抽卡：需有“被同调怪兽效果特殊召唤”的标记且当前玩家能抽卡。
	local b2=e:GetLabel()==1 and Duel.IsPlayerCanDraw(tp,1)
	-- 进入检索分支的前提：存在可检索的卡，且（不能抽卡或玩家选择不抽卡）时执行检索；否则进入抽卡分支。
	if b1 and (not b2 or not Duel.SelectYesNo(tp,aux.Stringid(id,2))) then  --"是否作为代替抽卡？"
		-- 显示提示信息，让玩家选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组选择1张满足s.thfilter的卡。
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的卡加入其持有者的手牌，原因记为效果。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 将检索加入手牌的卡展示给对方玩家确认。
			Duel.ConfirmCards(1-tp,g)
		end
	elseif e:GetLabel()==1 then
		-- 当选择抽卡代替检索时，当前玩家抽1张卡。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
-- 特殊召唤成功时的不入连锁辅助效果：若本次特殊召唤是由同调怪兽的效果（该效果为怪兽效果）进行的，则给此卡注册一个标记，用于②中判定“作为代替抽卡”的分支。
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if not re then return end
	if re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsType(TYPE_SYNCHRO) then
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD-RESET_TEMP_REMOVE,0,1)
	end
end
