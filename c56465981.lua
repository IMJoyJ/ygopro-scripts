--龍相剣現
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从卡组把1只「相剑」怪兽加入手卡。自己场上有同调怪兽存在的场合，也能作为代替把1只幻龙族怪兽加入手卡。
-- ②：这张卡被除外的场合，以自己场上1只「相剑」怪兽或者幻龙族怪兽为对象才能发动。那只怪兽的等级直到回合结束时上升或者下降1星。
function c56465981.initial_effect(c)
	-- ①：从卡组把1只「相剑」怪兽加入手卡。自己场上有同调怪兽存在的场合，也能作为代替把1只幻龙族怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(56465981,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,56465981)
	e1:SetTarget(c56465981.target)
	e1:SetOperation(c56465981.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡被除外的场合，以自己场上1只「相剑」怪兽或者幻龙族怪兽为对象才能发动。那只怪兽的等级直到回合结束时上升或者下降1星。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(56465981,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,56465982)
	e2:SetTarget(c56465981.lvtg)
	e2:SetOperation(c56465981.lvop)
	c:RegisterEffect(e2)
end
-- 过滤卡组中可以加入手卡的「相剑」怪兽，若满足check条件（场上有同调怪兽）则也可以是幻龙族怪兽
function c56465981.thfilter(c,check)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
		and ((check and c:IsRace(RACE_WYRM)) or c:IsSetCard(0x16b))
end
-- 过滤自己场上表侧表示的同调怪兽
function c56465981.checkfilter(c)
	return c:IsType(TYPE_SYNCHRO) and c:IsFaceup()
end
-- ①号效果的发动准备与合法性检测
function c56465981.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查自己场上是否存在表侧表示的同调怪兽
		local check=Duel.IsExistingMatchingCard(c56465981.checkfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查卡组中是否存在可加入手卡的「相剑」怪兽（若场上有同调怪兽，则也可以是幻龙族怪兽）
		return Duel.IsExistingMatchingCard(c56465981.thfilter,tp,LOCATION_DECK,0,1,nil,check)
	end
	-- 设置连锁处理的操作信息为：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①号效果的执行处理
function c56465981.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的同调怪兽
	local check=Duel.IsExistingMatchingCard(c56465981.checkfilter,tp,LOCATION_MZONE,0,1,nil)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足条件的怪兽卡
	local g=Duel.SelectMatchingCard(tp,c56465981.thfilter,tp,LOCATION_DECK,0,1,1,nil,check)
	if g:GetCount()>0 then
		-- 将选择的卡因效果加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤场上表侧表示、等级大于0的「相剑」怪兽或幻龙族怪兽
function c56465981.lvfilter(c)
	return (c:IsSetCard(0x16b) or (c:IsType(TYPE_MONSTER) and c:IsRace(RACE_WYRM))) and c:IsFaceup() and c:GetLevel()>0
end
-- ②号效果的发动准备、合法性检测及选择对象
function c56465981.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c56465981.lvfilter(chkc) end
	-- 在效果发动时，检查场上是否存在可作为对象的「相剑」怪兽或幻龙族怪兽
	if chk==0 then return Duel.IsExistingTarget(c56465981.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择1只符合条件的怪兽作为效果的对象
	Duel.SelectTarget(tp,c56465981.lvfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ②号效果的执行处理
function c56465981.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local sel=0
		local lvl=1
		if tc:IsLevel(1) then
			-- 若对象怪兽等级为1，则玩家只能选择“等级上升”选项
			sel=Duel.SelectOption(tp,aux.Stringid(56465981,2))  --"等级上升"
		else
			-- 若对象怪兽等级大于1，则让玩家选择“等级上升”或“等级下降”
			sel=Duel.SelectOption(tp,aux.Stringid(56465981,2),aux.Stringid(56465981,3))  --"等级上升/等级下降"
		end
		if sel==1 then
			lvl=-1
		end
		-- 那只怪兽的等级直到回合结束时上升或者下降1星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(lvl)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
