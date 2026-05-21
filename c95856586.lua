--ゼアル・フィールド
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：对方不能对应以自己场上的超量怪兽为对象的自己的卡的效果的发动把魔法·陷阱·怪兽的效果发动。
-- ②：自己场上有超量怪兽特殊召唤的场合，以那1只怪兽为对象才能发动。从自己的额外卡组·墓地选1只超量怪兽在作为对象的怪兽下面重叠作为超量素材。
-- ③：自己抽卡阶段的抽卡前才能发动。从卡组选1张「闪光抽卡」在卡组最上面放置。
function c95856586.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：对方不能对应以自己场上的超量怪兽为对象的自己的卡的效果的发动把魔法·陷阱·怪兽的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_FZONE)
	e2:SetOperation(c95856586.chainop)
	c:RegisterEffect(e2)
	-- ②：自己场上有超量怪兽特殊召唤的场合，以那1只怪兽为对象才能发动。从自己的额外卡组·墓地选1只超量怪兽在作为对象的怪兽下面重叠作为超量素材。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(95856586,0))  --"补充超量素材"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,95856586)
	e3:SetTarget(c95856586.mattg)
	e3:SetOperation(c95856586.matop)
	c:RegisterEffect(e3)
	-- ③：自己抽卡阶段的抽卡前才能发动。从卡组选1张「闪光抽卡」在卡组最上面放置。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(95856586,1))  --"「闪光抽卡」在卡组最上面放置"
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PREDRAW)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCondition(c95856586.tdcon)
	e4:SetTarget(c95856586.tdtg)
	e4:SetOperation(c95856586.tdop)
	c:RegisterEffect(e4)
end
-- 过滤条件：自己场上表侧表示的超量怪兽
function c95856586.cfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 在效果发动时，检查该效果是否以自己场上的超量怪兽为对象，若是则限制对方进行连锁
function c95856586.chainop(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return end
	-- 获取当前连锁的效果的对象卡片组
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if tg and tg:IsExists(c95856586.cfilter,1,nil,tp) and ep==tp then
		-- 设定连锁限制，使对方不能对应该效果的发动来发动效果
		Duel.SetChainLimit(c95856586.chainlm)
	end
end
-- 连锁限制条件：只有发动该效果的玩家可以进行连锁
function c95856586.chainlm(e,rp,tp)
	return tp==rp
end
-- 过滤条件：自己场上表侧表示、可以作为效果对象的超量怪兽
function c95856586.tgfilter(c,e,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsType(TYPE_XYZ)
		and c:IsLocation(LOCATION_MZONE) and c:IsCanBeEffectTarget(e)
end
-- 过滤条件：超量怪兽且可以作为超量素材叠放
function c95856586.matfilter(c)
	return c:IsType(TYPE_XYZ) and c:IsCanOverlay()
end
-- 效果②的发动准备：检查特殊召唤的怪兽中是否存在符合条件的超量怪兽，并确认额外卡组或墓地有可作为素材的超量怪兽
function c95856586.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and c95856586.tgfilter(chkc,e,tp) end
	if chk==0 then return eg:IsExists(c95856586.tgfilter,1,nil,e,tp)
		-- 检查自己的额外卡组或墓地是否存在可以作为超量素材的超量怪兽
		and Duel.IsExistingMatchingCard(c95856586.matfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil) end
	local g=eg
	if #eg>1 then
		-- 提示玩家选择效果的对象
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		g=eg:FilterSelect(tp,c95856586.tgfilter,1,1,nil,e,tp)
	end
	-- 将选择的怪兽设置为当前连锁的效果对象
	Duel.SetTargetCard(g)
end
-- 效果②的处理：将选定的额外卡组或墓地的超量怪兽作为超量素材叠放在对象怪兽下面
function c95856586.matop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		-- 提示玩家选择要作为超量素材的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
		-- 从自己的额外卡组或墓地选择1只不受墓地限制影响的超量怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c95856586.matfilter),tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的卡重叠在对象怪兽下面作为超量素材
			Duel.Overlay(tc,g)
		end
	end
end
-- 效果③的发动条件：当前是自己的回合，且卡组有卡，且有规则抽卡次数
function c95856586.tdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为自己的回合，且自己卡组的数量大于0
	return tp==Duel.GetTurnPlayer() and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0
		-- 检查自己本回合是否有规则抽卡次数
		and Duel.GetDrawCount(tp)>0
end
-- 过滤条件：卡名是「闪光抽卡」的卡
function c95856586.tdfilter(c)
	return c:IsCode(35906693)
end
-- 效果③的发动准备：检查卡组卡片数量是否大于1，且卡组中是否存在「闪光抽卡」
function c95856586.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组的卡片数量是否大于1
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>1
		-- 检查自己卡组中是否存在「闪光抽卡」
		and Duel.IsExistingMatchingCard(c95856586.tdfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果③的处理：从卡组选1张「闪光抽卡」，洗切卡组后将其放置在卡组最上面，并进行确认
function c95856586.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果卡组卡片数量小于等于1，则不处理
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<=1 then return end
	-- 提示玩家选择要放置在卡组最上面的卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(95856586,2))  --"请选择要放置在卡组最上面的卡"
	-- 从卡组中选择1张「闪光抽卡」
	local dc=Duel.SelectMatchingCard(tp,c95856586.tdfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if dc then
		-- 洗切玩家的卡组
		Duel.ShuffleDeck(tp)
		-- 将选中的卡移动到卡组最上面
		Duel.MoveSequence(dc,SEQ_DECKTOP)
		-- 确认玩家卡组最上方的一张卡
		Duel.ConfirmDecktop(tp,1)
	end
end
