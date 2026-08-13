--絶解なる獄神門－テルミナス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从卡组·额外卡组把1只「狱神」怪兽送去墓地。那之后，可以从卡组把1只天使族·暗属性怪兽加入手卡。这个回合，自己不用「狱神」怪兽不能攻击宣言。
-- ②：自己的「狱神」怪兽和对方怪兽进行战斗的伤害步骤开始时，把墓地的这张卡除外才能发动。那只对方怪兽里侧除外。
local s,id,o=GetID()
-- 创建并注册两个效果：①从卡组·额外卡组将1只「狱神」怪兽送去墓地，之后可将1只天使族·暗属性怪兽加入手卡，本回合非「狱神」怪兽不能攻击宣言；②自己的「狱神」怪兽与对方怪兽战斗的伤害步骤开始时，除外墓地的此卡为COST，将对方怪兽里侧除外；两效果各自1回合1次。
function s.initial_effect(c)
	-- 对应①效果原文：“①：从卡组·额外卡组把1只「狱神」怪兽送去墓地。那之后，可以从卡组把1只天使族·暗属性怪兽加入手卡。这个回合，自己不用「狱神」怪兽不能攻击宣言。”
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 对应②效果原文：“②：自己的「狱神」怪兽和对方怪兽进行战斗的伤害步骤开始时，把墓地的这张卡除外才能发动。那只对方怪兽里侧除外。”
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"除外"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.rmcon)
	-- 设置②的发动COST为把墓地的这张卡除外；发动时需先除外自身作为代价。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
end
-- 定义①的送墓过滤器：选择卡组·额外卡组中1只「狱神」怪兽，须为怪兽且能送去墓地。
function s.tgfilter(c)
	return c:IsSetCard(0x1ce) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- ①效果的发动条件和操作信息登记：发动时检查卡组/额外卡组是否有符合条件的「狱神」怪兽，并预登记本效果将把1张卡送去墓地。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动的合法性判定：卡组或额外卡组中是否存在至少1只满足s.tgfilter的「狱神」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil) end
	-- 登记操作信息：本效果处理时会将1张卡从卡组·额外卡组送去墓地（用于连锁响应与效果检测）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- 定义检索过滤器：选择卡组中1只天使族且暗属性的怪兽，须能加入手卡。
function s.thfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_FAIRY) and c:IsAbleToHand()
end
-- 处理①效果的前半段：从卡组·额外卡组选1只「狱神」怪兽送去墓地；若送墓成功且卡组存在符合条件的暗属性天使族怪兽，则询问玩家是否加入手卡。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出“请选择要送去墓地的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让当前玩家从卡组·额外卡组中选择1只符合条件的「狱神」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
	local tc=g:GetFirst()
	-- 判断所选怪兽是否确实被效果送去墓地且现在位于墓地，以此作为是否能继续检索的判定条件。
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE)
		-- 继续判断卡组中是否存在可加入手卡的暗属性天使族怪兽，并让玩家确认是否执行检索。
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否加入手卡？"
		-- 弹出“请选择要加入手牌的卡”的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让当前玩家从卡组中选择1只符合条件的暗属性天使族怪兽。
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 中断当前效果链，使后续的加入手卡处理被视为与之前的送墓处理不同时进行，避免因同时处理而错过时点。
			Duel.BreakEffect()
			-- 将选中的暗属性天使族怪兽以效果原因送回持有者手卡。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方玩家展示这张被检索加入手卡的卡片。
			Duel.ConfirmCards(1-tp,g)
		end
	end
	-- 对应①效果中的“这个回合，自己不用「狱神」怪兽不能攻击宣言。”及②效果全文：“②：自己的「狱神」怪兽和对方怪兽进行战斗的伤害步骤开始时，把墓地的这张卡除外才能发动。那只对方怪兽里侧除外。”
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.atktg)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 将这个回合内不能攻击宣言的限制效果注册到当前玩家，效果持续到回合结束。
	Duel.RegisterEffect(e3,tp)
end
-- 定义攻击限制的判定：不是「狱神」怪兽的怪兽不能进行攻击宣言。
function s.atktg(e,c)
	return not c:IsSetCard(0x1ce)
end
-- ②效果的发动条件：我方战斗怪兽为表侧「狱神」怪兽，其战斗对象为对方怪兽且可被里侧除外时满足条件，并保存那只对方怪兽。
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取我方正处于战斗中的怪兽。
	local ac=Duel.GetBattleMonster(tp)
	if not (ac and ac:IsFaceup() and ac:IsSetCard(0x1ce)) then return false end
	local bc=ac:GetBattleTarget()
	e:SetLabelObject(bc)
	return bc and bc:IsControler(1-tp) and bc:IsRelateToBattle() and bc:IsAbleToRemove(tp,POS_FACEDOWN)
end
-- ②效果的目标设定：本效果不取对象，发动时只需返回true并登记除外操作信息，具体对象在处理时确定。
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetLabelObject()
	if chk==0 then return true end
	-- 登记操作信息：本次效果将把之前保存的对方战斗怪兽里侧除外。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,bc,1,0,0)
end
-- ②效果处理：若对方战斗怪兽仍在场且与战斗相关，则将其里侧除外。
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetLabelObject()
	if bc and bc:IsControler(1-tp) and bc:IsType(TYPE_MONSTER) and bc:IsRelateToBattle() then
		-- 实际执行里侧除外：将符合条件的对方怪兽以里侧表示除外。
		Duel.Remove(bc,POS_FACEDOWN,REASON_EFFECT)
	end
end
