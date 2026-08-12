--ターボ・シンクロン
-- 效果：
-- ①：这张卡向攻击表示怪兽攻击宣言时才能发动。攻击对象怪兽变成守备表示。
-- ②：这张卡的攻击让自己受到战斗伤害时才能发动。把受到的战斗伤害数值以下的攻击力的1只怪兽从手卡特殊召唤。
function c67270095.initial_effect(c)
	-- ①：这张卡向攻击表示怪兽攻击宣言时才能发动。攻击对象怪兽变成守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(67270095,0))  --"攻击对象变成守备表示"
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetTarget(c67270095.postg)
	e1:SetOperation(c67270095.posop)
	c:RegisterEffect(e1)
	-- ②：这张卡的攻击让自己受到战斗伤害时才能发动。把受到的战斗伤害数值以下的攻击力的1只怪兽从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(67270095,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_DAMAGE)
	e2:SetCondition(c67270095.spcon)
	e2:SetTarget(c67270095.sptg)
	e2:SetOperation(c67270095.spop)
	c:RegisterEffect(e2)
end
-- ①号效果的发动准备，确认攻击对象是否为攻击表示、能否改变表示形式并将其设为效果对象
function c67270095.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前的攻击对象怪兽
	local d=Duel.GetAttackTarget()
	if chkc then return chkc==d end
	if chk==0 then return d and d:IsAttackPos() and d:IsCanChangePosition() and d:IsCanBeEffectTarget(e) end
	-- 将攻击对象怪兽设置为效果处理的对象
	Duel.SetTargetCard(d)
	-- 设置连锁信息，表示该效果包含改变表示形式的操作，对象为攻击对象怪兽，数量为1
	Duel.SetOperationInfo(0,CATEGORY_POSITION,d,1,0,0)
end
-- ①号效果的效果处理，将作为对象的怪兽变成表侧守备表示
function c67270095.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取之前设定的效果对象（即攻击对象怪兽）
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsAttackPos() then
		-- 将目标怪兽的表示形式改变为表侧守备表示
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
	end
end
-- ②号效果的发动条件判断函数
function c67270095.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断伤害是否由战斗产生、受伤害的玩家是否为自己，且攻击怪兽是否为这张卡自身
	return r==REASON_BATTLE and ep==tp and Duel.GetAttacker()==e:GetHandler()
end
-- 过滤函数：筛选手牌中攻击力在受到的战斗伤害数值以下、且可以特殊召唤的怪兽
function c67270095.filter(c,e,tp,dam)
	return c:IsAttackBelow(dam) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②号效果的发动准备，确认自己场上有空位且手牌中存在符合条件的怪兽
function c67270095.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查时，判断自己场上的主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且判断手牌中是否存在至少1只攻击力在受到的战斗伤害数值以下的怪兽
		and Duel.IsExistingMatchingCard(c67270095.filter,tp,LOCATION_HAND,0,1,nil,e,tp,ev) end
	-- 设置连锁信息，表示该效果包含从手牌特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ②号效果的效果处理，从手牌选择1只符合条件的怪兽特殊召唤
function c67270095.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，如果自己场上已经没有可用的主要怪兽区域，则不进行处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家发送提示信息，要求选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌中选择1只攻击力在受到的战斗伤害数值以下的怪兽
	local g=Duel.SelectMatchingCard(tp,c67270095.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp,ev)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己的场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
