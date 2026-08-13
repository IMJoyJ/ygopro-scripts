--D－HERO デビルロードガイ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合，以对方场上1只怪兽为对象才能发动。那只怪兽直到下次的准备阶段除外。
-- ②：从卡组把1只「命运英雄」怪兽送去墓地才能发动。从自己的卡组·墓地把1张「幽狱之时计塔」或「幽狱之时计都市-暗黑都市」加入手卡。这个效果的发动后，直到回合结束时自己不是暗属性「英雄」怪兽不能特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果：注册①效果（召唤·特殊召唤成功时触发除外对方怪兽的取对象诱发效果，1回合1次）和②效果（场上的起动检索效果，1回合1次）
function s.initial_effect(c)
	-- 在这张卡上登记记载有「幽狱之时计塔」(75041269)和「幽狱之时计都市-暗黑都市」(4663194)这两张卡的卡名
	aux.AddCodeList(c,75041269,4663194)
	-- ①：这张卡召唤·特殊召唤的场合，以对方场上1只怪兽为对象才能发动。那只怪兽直到下次的准备阶段除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：从卡组把1只「命运英雄」怪兽送去墓地才能发动。从自己的卡组·墓地把1张「幽狱之时计塔」或「幽狱之时计都市-暗黑都市」加入手卡。这个效果的发动后，直到回合结束时自己不是暗属性「英雄」怪兽不能特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"检索"
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCost(s.thcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 定义对象过滤函数：判定卡片是否可以被除外
function s.rmfilter(c)
	return c:IsAbleToRemove()
end
-- ①效果的对象选择处理：确认对方场上存在可除外的怪兽后，选择对方场上1只可除外的怪兽作为效果对象，并设置除外分类的操作信息
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.rmfilter(chkc) and chkc:IsControler(1-tp) end
	-- 发动条件检查：确认对方场上存在至少1只能成为效果对象且可以除外的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家提示：请选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择对方场上1只可除外的怪兽并将其设为当前连锁的效果对象
	local g=Duel.SelectTarget(tp,s.rmfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息：确定要除外所选择的1只目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- ①效果的处理：将目标怪兽暂时除外，并注册一个在下次准备阶段将其返回场上的持续效果（标记除外状态到回合结束，记录当前回合数以区分当前准备阶段）
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	-- 确认目标仍与此连锁相关且是怪兽卡后，将其以效果原因暂时除外
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,2,0,aux.Stringid(id,2))  --"直到下个准备阶段除外"
		-- 那只怪兽直到下次的准备阶段除外。从卡组把1只「命运英雄」怪兽送去墓地才能发动。从自己的卡组·墓地把1张「幽狱之时计塔」或「幽狱之时计都市-暗黑都市」加入手卡。这个效果的发动后，直到回合结束时自己不是暗属性「英雄」怪兽不能特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		-- 判断当前是否正处于准备阶段，以决定返回效果的有效期（当前准备阶段发动时需跳过本次准备阶段）
		if Duel.GetCurrentPhase()==PHASE_STANDBY then
			e1:SetReset(RESET_PHASE+PHASE_STANDBY,2)
		else
			e1:SetReset(RESET_PHASE+PHASE_STANDBY)
		end
		e1:SetLabelObject(tc)
		e1:SetCountLimit(1)
		e1:SetCondition(s.retcon)
		e1:SetOperation(s.retop)
		-- 记录当前回合数，用于在返回条件中识别是否已越过本次准备阶段
		e1:SetLabel(Duel.GetTurnCount())
		-- 把在准备阶段将被除外怪兽返回场上的效果注册到全局环境
		Duel.RegisterEffect(e1,tp)
	end
end
-- 定义返回效果的触发条件：回合数已变化（即新的准备阶段）且目标怪兽仍处于被暂时除外的标记状态
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 判定当前回合数不同于发动时记录的回合数，且被除外的怪兽仍带有本效果的除外标记
	return Duel.GetTurnCount()~=e:GetLabel() and tc:GetFlagEffect(id)~=0
end
-- 定义返回效果的处理：把被暂时除外的怪兽返回到场上
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 把被暂时除外的怪兽以离场前的表示形式返回到场上
	Duel.ReturnToField(e:GetLabelObject())
end
-- 定义cost过滤函数：判定是否为可送去墓地的「命运英雄」怪兽（系列码0xc008）
function s.tgfilter(c)
	return c:IsSetCard(0xc008) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- ②效果的cost处理：确认卡组存在可送去墓地的「命运英雄」怪兽后，选择其中1只送去墓地作为cost
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- cost检查：确认自己的卡组存在至少1只可送去墓地的「命运英雄」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向玩家提示：请选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己的卡组选择1只可送去墓地的「命运英雄」怪兽
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 把选择的「命运英雄」怪兽送去墓地作为cost
	Duel.SendtoGrave(g,REASON_COST)
end
-- 定义检索过滤函数：判定是否为可以加入手卡的「幽狱之时计塔」或「幽狱之时计都市-暗黑都市」
function s.thfilter(c)
	return c:IsCode(75041269,4663194) and c:IsAbleToHand()
end
-- ②效果的目标处理：确认自己的卡组·墓地存在可加入手卡的「幽狱之时计塔」或「幽狱之时计都市-暗黑都市」，并设置加入手卡分类的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：确认自己的卡组·墓地存在至少1张可加入手卡的「幽狱之时计塔」或「幽狱之时计都市-暗黑都市」
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置连锁操作信息：将从自己的卡组·墓地把1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- ②效果的处理：让玩家从自己的卡组·墓地选择1张「幽狱之时计塔」或「幽狱之时计都市-暗黑都市」（不受王家长眠之谷影响）加入手卡并向对方确认，之后注册直到回合结束时自己不能特殊召唤暗属性「英雄」怪兽以外怪兽的限制效果
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示：请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己的卡组·墓地选择1张符合条件的卡（套用王家长眠之谷过滤，确保不受其影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 把选择的卡以效果原因加入持有者手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 把加入手卡的卡展示给对方玩家确认
		Duel.ConfirmCards(1-tp,g)
	end
	-- 这个效果的发动后，直到回合结束时自己不是暗属性「英雄」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 把特殊召唤限制效果注册到全局环境，直到回合结束有效
	Duel.RegisterEffect(e1,tp)
end
-- 定义特殊召唤限制：不是暗属性「英雄」（系列码0x8）的怪兽不能特殊召唤
function s.splimit(e,c)
	return not (c:IsAttribute(ATTRIBUTE_DARK) and c:IsSetCard(0x8))
end
