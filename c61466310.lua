--帝王の開岩
-- 效果：
-- 「帝王的开岩」的②的效果1回合只能使用1次。
-- ①：只要这张卡在魔法与陷阱区域存在，自己不能从额外卡组把怪兽特殊召唤。
-- ②：自己以表侧表示对怪兽的上级召唤成功时，可以从以下效果选择1个发动。
-- ●和那只怪兽卡名不同的1只攻击力2400/守备力1000的怪兽从卡组加入手卡。
-- ●和那只怪兽卡名不同的1只攻击力2800/守备力1000的怪兽从卡组加入手卡。
function c61466310.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在，自己不能从额外卡组把怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c61466310.sumlimit)
	c:RegisterEffect(e2)
	-- ②：自己以表侧表示对怪兽的上级召唤成功时，可以从以下效果选择1个发动。●和那只怪兽卡名不同的1只攻击力2400/守备力1000的怪兽从卡组加入手卡。●和那只怪兽卡名不同的1只攻击力2800/守备力1000的怪兽从卡组加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(61466310,0))  --"检索"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,61466310)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCondition(c61466310.thcon)
	e3:SetTarget(c61466310.thtg)
	e3:SetOperation(c61466310.thop)
	c:RegisterEffect(e3)
end
-- 限制特殊召唤的区域为额外卡组
function c61466310.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsLocation(LOCATION_EXTRA)
end
-- 检查是否为自己将怪兽上级召唤成功
function c61466310.thcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and eg:GetFirst():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 过滤卡组中攻击力为2400或2800、守备力为1000且卡名与上级召唤的怪兽不同的可检索怪兽
function c61466310.filter(c,code)
	return c:IsAttack(2400,2800) and c:IsDefense(1000) and not c:IsCode(code) and c:IsAbleToHand()
end
-- 过滤卡组中指定攻击力、守备力为1000且卡名与上级召唤的怪兽不同的可检索怪兽
function c61466310.filter2(c,atk,code)
	return c:IsAttack(atk) and c:IsDefense(1000) and not c:IsCode(code) and c:IsAbleToHand()
end
-- 效果发动的可行性检查与分支效果的选择
function c61466310.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查卡组中是否存在至少1只满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c61466310.filter,tp,LOCATION_DECK,0,1,nil,eg:GetFirst():GetCode()) end
	-- 检查卡组中是否存在满足条件的攻击力2400/守备力1000的怪兽
	local t1=Duel.IsExistingMatchingCard(c61466310.filter2,tp,LOCATION_DECK,0,1,nil,2400,eg:GetFirst():GetCode())
	-- 检查卡组中是否存在满足条件的攻击力2800/守备力1000的怪兽
	local t2=Duel.IsExistingMatchingCard(c61466310.filter2,tp,LOCATION_DECK,0,1,nil,2800,eg:GetFirst():GetCode())
	-- 若两类怪兽都存在，则让玩家选择其中一个效果发动，并将选择结果记录在Label中
	if t1 and t2 then e:SetLabel(Duel.SelectOption(tp,aux.Stringid(61466310,1),aux.Stringid(61466310,2)))  --"攻击力2400/守备力1000的怪兽/攻击力2800/守备力1000的怪兽"
	-- 若仅存在攻击力2400的怪兽，则强制选择该效果，并将Label设为0
	elseif t1 then e:SetLabel(Duel.SelectOption(tp,aux.Stringid(61466310,1)))  --"攻击力2400/守备力1000的怪兽"
	-- 若仅存在攻击力2800的怪兽，则强制选择该效果，并将Label设为1
	else e:SetLabel(Duel.SelectOption(tp,aux.Stringid(61466310,2))+1) end  --"攻击力2800/守备力1000的怪兽"
	-- 设置连锁处理的操作信息为从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	eg:GetFirst():CreateEffectRelation(e)
end
-- 检索效果的具体执行处理
function c61466310.thop(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	if ec:IsFacedown() or not ec:IsRelateToEffect(e) then return end
	local atk=e:GetLabel()==0 and 2400 or 2800
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足对应攻击力/守备力条件且卡名不同的怪兽
	local g=Duel.SelectMatchingCard(tp,c61466310.filter2,tp,LOCATION_DECK,0,1,1,nil,atk,ec:GetCode())
	if g:GetCount()>0 then
		-- 将选中的怪兽加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
