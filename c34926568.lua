--守護獣セルケト
-- 效果：
-- 这张卡不能通常召唤。「守护兽 塞勒凯特」1回合1次在自己场上有「王家的神殿」存在的状态，从手卡·卡组把1只10星以上的怪兽除外的场合可以特殊召唤。
-- ①：1回合1次，自己主要阶段才能发动。把1张「王家的神殿」或者有那个卡名记述的魔法卡从卡组加入手卡。
-- ②：这张卡和对方怪兽进行战斗的伤害步骤开始时才能发动。那只对方怪兽破坏，这张卡的攻击力上升破坏的怪兽的原本攻击力一半数值。
local s,id,o=GetID()
-- 初始化效果注册：为「守护兽 塞勒凯特」注册特殊召唤规则效果（手卡除外10星以上怪兽特殊召唤）、①检索「王家的神殿」或记载其卡名的魔法卡的效果、②战斗时破坏对方怪兽并提升攻击力的效果。
function s.initial_effect(c)
	-- 记录此卡效果文本中记载了「王家的神殿」（卡号29762407），使 aux.IsCodeListed 等判定能够识别该关联。
	aux.AddCodeList(c,29762407)
	c:EnableReviveLimit()
	-- 「这张卡不能通常召唤。「守护兽 塞勒凯特」1回合1次在自己场上有「王家的神殿」存在的状态，从手卡·卡组把1只10星以上的怪兽除外的场合可以特殊召唤。」
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(s.sprcon)
	e1:SetTarget(s.sprtg)
	e1:SetOperation(s.sprop)
	c:RegisterEffect(e1)
	-- 「①：1回合1次，自己主要阶段才能发动。把1张「王家的神殿」或者有那个卡名记述的魔法卡从卡组加入手卡。」
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- 「②：这张卡和对方怪兽进行战斗的伤害步骤开始时才能发动。那只对方怪兽破坏，这张卡的攻击力上升破坏的怪兽的原本攻击力一半数值。」
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"破坏"
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_START)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
-- 定义代价筛选函数：用于判断手卡·卡组中的怪兽是否能作为特殊召唤代价被除外，要求10星以上且可以被除外。
function s.cfilter(c,tp)
	return c:IsAbleToRemoveAsCost() and c:IsAbleToRemove(tp,POS_FACEUP,REASON_SPSUMMON) and c:IsLevelAbove(10)
end
-- 特殊召唤规则效果的条件：自己场上有表侧表示的「王家的神殿」，手卡·卡组存在可除外的10星以上怪兽，且主怪兽区有空位。
function s.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上的主要怪兽区是否有空位可供特殊召唤。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡或卡组中是否存在除自身以外满足代价条件（10星以上、可除外）的怪兽。
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,c,tp)
		-- 检查自己场上有表侧表示且卡名为「王家的神殿」的卡存在。
		and Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsCode),tp,LOCATION_ONFIELD,0,1,nil,29762407)
end
-- 特殊召唤规则效果的目标选择：从手卡·卡组选择一只10星以上的怪兽作为特殊召唤代价，并保存到效果标签中。
function s.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取手卡·卡组中所有满足除外面板条件的怪兽，排除特殊召唤的这张卡自身。
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND+LOCATION_DECK,0,c,tp)
	-- 向玩家显示选择除外怪兽的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则效果的处理：执行代价，将之前选择的怪兽除外，完成特殊召唤手续。
function s.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选择的怪兽以表侧表示除外，除外原因记为该怪兽的特殊召唤。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
end
-- 定义检索过滤条件：卡名是「王家的神殿」（29762407），或者是效果文本中记载了「王家的神殿」卡名的魔法卡，且该卡可以加入手卡。
function s.thfilter(c)
	-- 检索条件核心：目标卡必须是「王家的神殿」本身，或是记载了「王家的神殿」的魔法卡，并且当前可以加入手卡。
	return (c:IsCode(29762407) or aux.IsCodeListed(c,29762407) and c:IsType(TYPE_SPELL)) and c:IsAbleToHand()
end
-- ①效果的发动判定：若为发动前检查，确认卡组中存在满足检索条件的卡；同时设置操作信息为检索回手牌。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：卡组里是否存在至少1张满足检索条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设定本次效果处理的操作信息，表示将进行从卡组把卡加入手卡的“检索”处理。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理：从卡组选择1张符合条件的卡加入手卡，并让对方确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择要加入手牌的卡的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己的卡组中选择1张满足 s.thfilter 条件的卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡加入其持有者的手卡，原因记为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将检索到的卡给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果的发动条件：本卡与对方怪兽进行战斗的伤害步骤开始时，以那只对方怪兽为对象；保存对象并设置破坏的操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetHandler():GetBattleTarget()
	if chk==0 then return tc and tc:IsControler(1-tp) end
	e:SetLabelObject(tc)
	-- 设置本次效果处理的操作信息：将对方怪兽作为将被破坏的对象。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
end
-- ②效果的处理：若战斗对象仍相关且是对方怪兽，先将其破坏；破坏成功且本卡仍在场上并关联此效果时，本卡攻击力上升那只怪兽原本攻击力的一半。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	-- 综合判断是否满足全部处理条件：对方怪兽仍与战斗相关、是怪兽、属于对方，且能成功破坏；同时本卡表侧在场且与效果关联。
	if tc and tc:IsRelateToBattle() and tc:IsType(TYPE_MONSTER) and tc:IsControler(1-tp) and Duel.Destroy(tc,REASON_EFFECT)~=0
		and c:IsFaceup() and c:IsRelateToEffect(e) then
		local atk=tc:GetTextAttack()
		if atk<0 then atk=0 end
		if atk>0 then
			-- 「这张卡的攻击力上升破坏的怪兽的原本攻击力一半数值。」
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(math.ceil(atk/2))
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e1)
		end
	end
end
