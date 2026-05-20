--No.75 惑乱のゴシップ・シャドー
-- 效果：
-- 3星怪兽×2只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：1回合1次，对方把怪兽的效果发动时，把这张卡2个超量素材取除才能发动。那个效果变成「双方各自抽1张」。
-- ②：以自己场上1只其他的「No.」超量怪兽为对象才能发动。把这张卡作为那只怪兽的超量素材（这张卡持有超量素材的场合，那些也全部作为超量素材）。
function c71166481.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加超量召唤手续：等级3怪兽2只以上，最多7只
	aux.AddXyzProcedure(c,nil,3,2,nil,nil,7)
	-- ①：1回合1次，对方把怪兽的效果发动时，把这张卡2个超量素材取除才能发动。那个效果变成「双方各自抽1张」。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(71166481,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c71166481.chcon)
	e1:SetCost(c71166481.chcost)
	e1:SetTarget(c71166481.chtg)
	e1:SetOperation(c71166481.chop)
	c:RegisterEffect(e1)
	-- ②：以自己场上1只其他的「No.」超量怪兽为对象才能发动。把这张卡作为那只怪兽的超量素材（这张卡持有超量素材的场合，那些也全部作为超量素材）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(71166481,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,71166481)
	e2:SetTarget(c71166481.xtg)
	e2:SetOperation(c71166481.xop)
	c:RegisterEffect(e2)
end
-- 设置该卡片的「No.」数值为75
aux.xyz_number[71166481]=75
-- 效果①的发动条件判定：对方发动怪兽的效果时
function c71166481.chcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER) and rp==1-tp
end
-- 效果①的代价：取除这张卡的2个超量素材
function c71166481.chcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- 效果①的发动准备：确认双方玩家是否都能抽卡
function c71166481.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 检查对方玩家是否可以抽卡
		and Duel.IsPlayerCanDraw(1-tp,1) end
end
-- 效果①的效果处理：将当前连锁的效果处理替换为双方抽卡的效果
function c71166481.chop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	-- 清空当前连锁的对象
	Duel.ChangeTargetCard(ev,g)
	-- 将当前连锁的效果处理替换为指定的函数（双方各自抽1张）
	Duel.ChangeChainOperation(ev,c71166481.repop)
end
-- 替换后的效果处理：双方各自抽1张卡
function c71166481.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 自身玩家因效果抽1张卡
	Duel.Draw(tp,1,REASON_EFFECT)
	-- 对方玩家因效果抽1张卡
	Duel.Draw(1-tp,1,REASON_EFFECT)
end
-- 过滤条件：自己场上表侧表示的「No.」超量怪兽
function c71166481.xfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0x48)
end
-- 效果②的发动准备与对象选择
function c71166481.xtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c71166481.xfilter(chkc) and chkc~=c end
	-- 检查自己场上是否存在除自身以外的其他合法的「No.」超量怪兽作为对象，且自身可以作为超量素材
	if chk==0 then return Duel.IsExistingTarget(c71166481.xfilter,tp,LOCATION_MZONE,0,1,c)
		and c:IsCanOverlay() end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只其他的「No.」超量怪兽作为效果对象
	Duel.SelectTarget(tp,c71166481.xfilter,tp,LOCATION_MZONE,0,1,1,c)
end
-- 效果②的效果处理：将这张卡及其超量素材全部重叠在目标怪兽下作为超量素材
function c71166481.xop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) and c:IsCanOverlay() then
		local mg=c:GetOverlayGroup()
		-- 若这张卡持有超量素材，将那些素材全部重叠在目标怪兽下作为超量素材
		if mg:GetCount()>0 then Duel.Overlay(tc,mg,false) end
		-- 将这张卡自身重叠在目标怪兽下作为超量素材
		Duel.Overlay(tc,Group.FromCards(c))
	end
end
