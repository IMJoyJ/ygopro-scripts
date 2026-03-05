--キラーチューン・ミクス
-- 效果：
-- 场上的这张卡为素材作同调召唤的场合，手卡1只调整也能作为同调素材。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从自己的卡组·墓地把2星怪兽以外的1只「杀手级调整曲」怪兽加入手卡。
-- ②：这张卡作为同调素材送去墓地的场合，以对方场上1只怪兽为对象才能发动。那只怪兽破坏。
local s,id,o=GetID()
-- 初始化效果函数，注册所有效果
function s.initial_effect(c)
	-- 场上的这张卡为素材作同调召唤的场合，手卡1只调整也能作为同调素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetCondition(s.syncon)
	e1:SetCode(EFFECT_HAND_SYNCHRO)
	e1:SetTargetRange(0,1)
	e1:SetTarget(s.tfilter)
	c:RegisterEffect(e1)
	-- 这张卡召唤·特殊召唤的场合才能发动。从自己的卡组·墓地把2星怪兽以外的1只「杀手级调整曲」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"检索效果"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- 这张卡作为同调素材送去墓地的场合，以对方场上1只怪兽为对象才能发动。那只怪兽破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"破坏效果"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_BE_MATERIAL)
	e4:SetCountLimit(1,id+o)
	e4:SetCondition(s.descon)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
	s.killer_tune_be_material_effect=e4
end
-- 同调素材过滤器，只允许调整类型作为同调素材
function s.tfilter(e,c)
	return c:IsSynchroType(TYPE_TUNER)
end
-- 同调条件，只有在主要怪兽区时才能触发
function s.syncon(e)
	return e:GetHandler():IsLocation(LOCATION_MZONE)
end
-- 检索过滤器，筛选「杀手级调整曲」且非2星的怪兽
function s.filter(c)
	return c:IsSetCard(0x1d5) and c:IsType(TYPE_MONSTER) and not c:IsLevel(2)
		and c:IsAbleToHand()
end
-- 检索效果的发动条件判断和操作信息设置
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足检索条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置检索效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 检索效果的处理函数，选择并加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 破坏效果的发动条件，只有作为同调素材送去墓地时才能发动
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 破坏效果的目标选择和操作信息设置
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 判断是否满足破坏效果的目标条件
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择破坏目标
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置破坏效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的处理函数，对目标怪兽进行破坏
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) then
		-- 对目标卡进行破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
