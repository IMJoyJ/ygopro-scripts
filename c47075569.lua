--EMペンデュラム・マジシャン
-- 效果：
-- ←2 【灵摆】 2→
-- ①：自己场上有「娱乐伙伴」怪兽灵摆召唤的场合发动。自己场上的全部「娱乐伙伴」怪兽的攻击力直到回合结束时上升1000。
-- 【怪兽效果】
-- 这个卡名的怪兽效果1回合只能使用1次。
-- ①：这张卡特殊召唤的场合，以自己场上最多2张卡为对象才能发动。那些卡破坏，把破坏数量的「娱乐伙伴 灵摆魔术家」以外的「娱乐伙伴」怪兽从卡组加入手卡（同名卡最多1张）。
function c47075569.initial_effect(c)
	-- 为这张卡添加灵摆怪兽的基本属性（灵摆召唤、灵摆刻度、灵摆区域的卡发动等），使其成为可放置于灵摆区的灵摆怪兽。
	aux.EnablePendulumAttribute(c)
	-- ①：自己场上有「娱乐伙伴」怪兽灵摆召唤的场合发动。自己场上的全部「娱乐伙伴」怪兽的攻击力直到回合结束时上升1000。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c47075569.atkcon)
	e2:SetOperation(c47075569.atkop)
	c:RegisterEffect(e2)
	-- 这个卡名的怪兽效果1回合只能使用1次。①：这张卡特殊召唤的场合，以自己场上最多2张卡为对象才能发动。那些卡破坏，把破坏数量的「娱乐伙伴 灵摆魔术家」以外的「娱乐伙伴」怪兽从卡组加入手卡（同名卡最多1张）。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,47075569)
	e3:SetTarget(c47075569.thtg)
	e3:SetOperation(c47075569.thop)
	c:RegisterEffect(e3)
end
-- 检查一张怪兽卡是否满足：表侧表示、属于「娱乐伙伴」系列、控制者为当前玩家、且是通过灵摆召唤出场的怪兽；用于筛选灵摆召唤成功的事件中的目标怪兽。
function c47075569.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x9f) and c:IsControler(tp) and c:IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- 灵摆效果的发动条件：在特殊召唤成功的怪兽群中，检查是否存在至少1只满足我方表侧「娱乐伙伴」灵摆召唤条件的怪兽；若存在则条件成立。
function c47075569.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c47075569.cfilter,1,nil,tp)
end
-- 筛选场上表侧表示且属于「娱乐伙伴」系列的怪兽，用于选择攻击力提升的对象。
function c47075569.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x9f)
end
-- 灵摆效果的处理：取得我方场上所有表侧表示且属于「娱乐伙伴」的怪兽，逐只注册使其攻击力上升1000、直到回合结束的永续效果。
function c47075569.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得我方怪兽区域中所有满足filter条件的表侧「娱乐伙伴」怪兽，作为后续攻击力上升的对象集合。
	local g=Duel.GetMatchingGroup(c47075569.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 自己场上的全部「娱乐伙伴」怪兽的攻击力直到回合结束时上升1000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
-- 筛选卡组中可作为检索对象的怪兽：属于「娱乐伙伴」系列、是怪兽卡、卡名不是「娱乐伙伴 灵摆魔术家」自身、并且能够加入手卡。
function c47075569.thfilter(c)
	return c:IsSetCard(0x9f) and c:IsType(TYPE_MONSTER) and not c:IsCode(47075569) and c:IsAbleToHand()
end
-- 怪兽效果的发动目标与合法性判定：在变更对象时确认对象是我方场上卡片；在发动时确认场上存在至少1个可破坏对象且卡组存在至少1张可检索的「娱乐伙伴」怪兽。
function c47075569.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsOnField() end
	-- 发动合法性检查：确认我方场上有至少1张可以成为效果对象的卡（用于破坏），否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,0,1,nil)
		-- 发动合法性检查：确认我方卡组中存在至少1张满足检索条件的「娱乐伙伴」怪兽可加入手卡；与场上对象条件共同构成发动前提。
		and Duel.IsExistingMatchingCard(c47075569.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 取得我方卡组中所有满足检索条件的「娱乐伙伴」怪兽，用于计算可选检索数量并限制同名卡最多1张。
	local g=Duel.GetMatchingGroup(c47075569.thfilter,tp,LOCATION_DECK,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	if ct>2 then ct=2 end
	-- 向玩家发出选择提示消息，提示内容为“请选择要破坏的卡”，引导玩家选择下方的破坏对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从自己场上选择1至ct张卡（ct最多为2）作为取对象效果的目标，并将这些卡登记为当前连锁的对象。
	local dg=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,0,1,ct,nil)
	-- 向连锁系统登记本次效果包含“破坏”分类，破坏对象为已选择的卡片集合，数量为选择张数；供后续其他卡片的联动判断使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,dg:GetCount(),0,0)
	-- 向连锁系统登记本次效果会从卡组加入手卡，数量与破坏数相同，来源为我方卡组；具体加入的卡在效果处理时确定，因此对象为nil。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,dg:GetCount(),tp,LOCATION_DECK)
end
-- 怪兽效果的实际处理：取出本次连锁的取对象卡片并过滤无效对象，将其破坏；若实际破坏数为0或卡组无可用检索卡则结束；否则从卡组中选出与破坏数相同、卡名各不相同的「娱乐伙伴」怪兽（除自身）加入手卡，并向对方确认。
function c47075569.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理时登记的对象卡组，并筛选出仍然与效果e存在联系的卡，作为实际破坏的对象集合。
	local dg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 以效果原因破坏筛选后的对象卡，并记录实际被破坏的数量ct；后续决定从卡组加入手卡的数量。
	local ct=Duel.Destroy(dg,REASON_EFFECT)
	-- 取得我方卡组中所有满足检索条件的「娱乐伙伴」怪兽，形成候选组g，用于后续选择加入手卡的卡。
	local g=Duel.GetMatchingGroup(c47075569.thfilter,tp,LOCATION_DECK,0,nil)
	if ct==0 or g:GetCount()==0 then return end
	if ct>g:GetClassCount(Card.GetCode) then return end
	-- 向玩家发出选择提示消息，提示内容为“请选择要加入手牌的卡”，引导玩家从候选组中选择加入手卡的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从候选组g中让玩家选择ct张卡且这些卡卡名互不相同，确保“同名卡最多1张”，满足效果的限制。
	local g1=g:SelectSubGroup(tp,aux.dncheck,false,ct,ct)
	-- 将选中的卡片以效果原因加入持有者的手卡，完成“从卡组加入手卡”的处理。
	Duel.SendtoHand(g1,nil,REASON_EFFECT)
	-- 将实际加入手卡的卡片展示给对手（1-tp），让双方确认检索结果，符合规则中检索卡片的公开要求。
	Duel.ConfirmCards(1-tp,g1)
end
