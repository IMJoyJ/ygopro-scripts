--冥帝王エイドス
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从自己的卡组·墓地把1张「帝王」魔法·陷阱卡或者1只攻击力2800/守备力1000的怪兽加入手卡。
-- ②：宣言1个属性才能发动。场上1只怪兽的属性变成宣言的属性。
-- ③：这张卡在墓地存在的状态，自己把攻击力2400以上而守备力1000的怪兽上级召唤的场合才能发动。这张卡加入手卡或特殊召唤。
local s,id,o=GetID()
-- 初始化效果，创建3个效果，分别对应①②③效果
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从自己的卡组·墓地把1张「帝王」魔法·陷阱卡或者1只攻击力2800/守备力1000的怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：宣言1个属性才能发动。场上1只怪兽的属性变成宣言的属性。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.cttg)
	e3:SetOperation(s.ctop)
	c:RegisterEffect(e3)
	-- ③：这张卡在墓地存在的状态，自己把攻击力2400以上而守备力1000的怪兽上级召唤的场合才能发动。这张卡加入手卡或特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,id+o*2)
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
-- 定义过滤函数，筛选满足条件的「帝王」魔法·陷阱卡或攻击力2800/守备力1000的怪兽
function s.filter(c)
	return (c:IsSetCard(0xbe) and c:IsType(TYPE_SPELL+TYPE_TRAP) or c:IsType(TYPE_MONSTER) and c:IsAttack(2800) and c:IsDefense(1000))
		and c:IsAbleToHand()
end
-- ①效果的发动条件判断和操作信息设置
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足①效果发动条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置①效果操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- ①效果的处理函数，选择并加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果的发动条件判断和操作信息设置
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local att=0
	-- 获取场上所有表侧表示的怪兽
	local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 遍历场上表侧表示的怪兽，计算可宣言的属性
	for tc in aux.Next(mg) do
		att=att|(ATTRIBUTE_ALL&~tc:GetAttribute())
	end
	if chk==0 then return att>0 end
	-- 提示玩家宣言属性
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 让玩家宣言一个属性
	local aatt=Duel.AnnounceAttribute(tp,1,att)
	e:SetLabel(aatt)
end
-- ②效果的处理函数，改变目标怪兽属性
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local att=e:GetLabel()
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,aux.AND(Card.IsFaceup,aux.NOT(Card.IsAttribute)),tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,att)
	if g:GetCount()>0 then
		-- 显示选中怪兽被选为对象
		Duel.HintSelection(g)
		local tc=g:GetFirst()
		-- 设置目标怪兽属性改变效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(att)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- ③效果的发动条件判断
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return tc:IsSummonPlayer(tp) and tc:IsSummonType(SUMMON_TYPE_ADVANCE)
		and tc:IsAttackAbove(2400) and tc:IsDefense(1000)
end
-- ③效果的发动条件判断和操作信息设置
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断是否满足③效果发动条件
	if chk==0 then return c:IsAbleToHand() or Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置③效果操作信息（回手）
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
	-- 设置③效果操作信息（特殊召唤）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ③效果的处理函数，选择回手或特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断③效果是否可以发动
	if not c:IsRelateToChain() or not aux.NecroValleyFilter()(c) then return end
	local b1=c:IsAbleToHand()
	-- 判断是否可以特殊召唤
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	-- 让玩家选择回手或特殊召唤
	local op=aux.SelectFromOptions(tp,{b1,1190,1},{b2,1152,2})
	if op==1 then
		-- 将卡加入手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,c)
	elseif op==2 then
		-- 将卡特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
