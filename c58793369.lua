--竜輝巧－ファフニール
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把「龙辉巧-扶筐增二」以外的1张「龙辉巧」魔法·陷阱卡加入手卡。
-- ②：仪式魔法卡的效果的发动以及那些发动的效果不会被无效化。
-- ③：1回合1次，自己场上有「龙辉巧」怪兽存在的状态，怪兽表侧表示召唤·特殊召唤的场合才能发动。这个回合，那些表侧表示怪兽的等级下降那攻击力每1000为1星的数值（最少到1星）。
function c58793369.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，可以从卡组把「龙辉巧-扶筐增二」以外的1张「龙辉巧」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,58793369+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c58793369.activate)
	c:RegisterEffect(e1)
	-- ②：仪式魔法卡的效果的发动以及那些发动的效果不会被无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_INACTIVATE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetValue(c58793369.effectfilter)
	c:RegisterEffect(e2)
	-- ②：仪式魔法卡的效果的发动以及那些发动的效果不会被无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_DISEFFECT)
	e3:SetRange(LOCATION_FZONE)
	e3:SetValue(c58793369.effectfilter)
	c:RegisterEffect(e3)
	-- ③：1回合1次，自己场上有「龙辉巧」怪兽存在的状态，怪兽表侧表示召唤·特殊召唤的场合才能发动。这个回合，那些表侧表示怪兽的等级下降那攻击力每1000为1星的数值（最少到1星）。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(58793369,1))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e4:SetCondition(c58793369.lvcon)
	e4:SetTarget(c58793369.lvtg)
	e4:SetOperation(c58793369.lvop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e5)
end
-- 过滤卡组中「龙辉巧-扶筐增二」以外的「龙辉巧」魔法·陷阱卡
function c58793369.thfilter(c)
	return c:IsSetCard(0x154) and c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsCode(58793369) and c:IsAbleToHand()
end
-- 卡片发动时的效果处理，从卡组检索符合条件的「龙辉巧」魔法·陷阱卡
function c58793369.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有符合检索条件的卡片
	local g=Duel.GetMatchingGroup(c58793369.thfilter,tp,LOCATION_DECK,0,nil)
	-- 若卡组中存在符合条件的卡，则询问玩家是否选择发动检索效果
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(58793369,0)) then  --"是否把「龙辉巧」魔法·陷阱卡加入手卡？"
		-- 设置选择卡片加入手牌的提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡片加入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 过滤需要保护的连锁，判断其是否为仪式魔法卡的效果发动
function c58793369.effectfilter(e,ct)
	-- 获取指定连锁的卡片具体类型
	local etype=Duel.GetChainInfo(ct,CHAININFO_EXTTYPE)
	return etype&(TYPE_RITUAL+TYPE_SPELL)==TYPE_RITUAL+TYPE_SPELL
end
-- 过滤自己场上表侧表示的「龙辉巧」怪兽
function c58793369.confilter(c)
	return c:IsFaceup() and c:IsSetCard(0x154)
end
-- 过滤等级在2星以上、攻击力在1000以上且表侧表示的怪兽
function c58793369.lvfilter(c,e)
	return c:IsFaceup() and c:IsLevelAbove(2) and c:IsAttackAbove(1000) and (not e or c:IsRelateToEffect(e))
end
-- 判断效果③的发动条件是否满足（自己场上有「龙辉巧」怪兽存在，且有符合条件的怪兽表侧表示召唤·特殊召唤）
function c58793369.lvcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上表侧表示的「龙辉巧」怪兽
	local g=Duel.GetMatchingGroup(c58793369.confilter,tp,LOCATION_MZONE,0,nil)
	return eg:IsExists(c58793369.lvfilter,1,nil,nil) and #g-eg:Filter(c58793369.confilter,nil):FilterCount(Card.IsControler,nil,tp)>0
end
-- 效果③的靶向处理，将召唤·特殊召唤的怪兽设为效果处理对象
function c58793369.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将本次召唤·特殊召唤的怪兽群设为效果处理的目标
	Duel.SetTargetCard(eg)
end
-- 效果③的实际处理，使召唤·特殊召唤的怪兽等级下降其攻击力每1000为1星的数值
function c58793369.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=eg:Filter(c58793369.lvfilter,nil,e)
	local tc=g:GetFirst()
	while tc do
		local atk=tc:GetAttack()
		local lv=math.floor(atk/1000)
		-- 这个回合，那些表侧表示怪兽的等级下降那攻击力每1000为1星的数值（最少到1星）。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(-lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
