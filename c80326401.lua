--青き眼の祈り
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：丢弃1张手卡才能发动。除「青色眼睛的祈祷」外的1张有「青眼白龙」的卡名记述的魔法·陷阱卡和1只光属性·1星调整从卡组加入手卡。
-- ②：把墓地的这张卡除外，以自己场上1只「青眼白龙」为对象才能发动。从额外卡组把1只「青眼」怪兽当作攻击力上升400的装备魔法卡使用给作为对象的怪兽装备。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- 将「青眼白龙」（卡号89631139）放入该卡的关联卡片列表中
	aux.AddCodeList(c,89631139)
	-- ①：丢弃1张手卡才能发动。除「青色眼睛的祈祷」外的1张有「青眼白龙」的卡名记述的魔法·陷阱卡和1只光属性·1星调整从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己场上1只「青眼白龙」为对象才能发动。从额外卡组把1只「青眼」怪兽当作攻击力上升400的装备魔法卡使用给作为对象的怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"装备"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 设置效果②的发动代价为：把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
end
-- 效果①的发动代价（Cost）函数：丢弃1张手卡
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查手牌中是否存在除这张卡以外的可丢弃卡片
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,c) end
	-- 玩家选择并丢弃1张手牌作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,nil)
end
-- 检索条件过滤函数1：除「青色眼睛的祈祷」外、记有「青眼白龙」卡名的魔法·陷阱卡，且卡组中存在满足条件2的卡
function s.thfilter1(c,tp)
	-- 过滤出除本名卡以外、记有「青眼白龙」卡名的可检索魔陷卡
	return not c:IsCode(id) and aux.IsCodeListed(c,89631139) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
		-- 并且卡组中存在至少1张不与当前选择卡相同的、满足条件2的卡
		and Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,c)
end
-- 检索条件过滤函数2：光属性·1星调整怪兽
function s.thfilter2(c)
	return c:IsLevel(1) and c:IsType(TYPE_TUNER) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToHand()
end
-- 效果①的发动检测与效果分类注册函数
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足检索条件的卡片组合
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_DECK,0,1,nil,tp) end
	-- 注册连锁处理信息：从卡组将2张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
-- 效果①的实际效果处理函数
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组选择1张满足条件1的魔陷卡
	local tc=Duel.SelectMatchingCard(tp,s.thfilter1,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	-- 如果成功选出第一张卡，且卡组中仍存在满足条件2的卡
	if tc and Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,tc) then
		-- 提示玩家选择要加入手牌的第二张卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 玩家从卡组选择1张满足条件2的光属性·1星调整
		local g=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,tc)
		g:AddCard(tc)
		-- 将选出的2张卡加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②的对象过滤函数：自己场上表侧表示的「青眼白龙」
function s.tgfilter(c)
	return c:IsFaceup() and c:IsCode(89631139)
end
-- 效果②的装备怪兽过滤函数：额外卡组的「青眼」怪兽
function s.eqfilter(c)
	return c:IsSetCard(0xdd) and c:IsType(TYPE_MONSTER)
end
-- 效果②的发动检测与对象选择函数
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tgfilter(chkc) end
	-- 检查自己场上是否有可用的魔法与陷阱区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 并且自己场上存在可以作为效果对象的「青眼白龙」
		and Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 并且额外卡组存在可装备的「青眼」怪兽
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 提示玩家选择要装备的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 玩家选择自己场上1只「青眼白龙」作为效果对象
	Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果②的实际效果处理函数
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的「青眼白龙」
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍存在于场上且表侧表示，以及魔法与陷阱区域是否有空位
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		-- 提示玩家选择要装备的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 玩家从额外卡组选择1只「青眼」怪兽
		local g=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_EXTRA,0,1,1,nil)
		local ec=g:GetFirst()
		if ec then
			-- 将选出的额外卡组怪兽作为装备卡装备给对象怪兽，若装备失败则结束处理
			if not Duel.Equip(tp,ec,tc) then return end
			-- 当作装备魔法卡使用给作为对象的怪兽装备
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetLabelObject(tc)
			e1:SetValue(s.eqlimit)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			ec:RegisterEffect(e1)
			-- 攻击力上升400
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_EQUIP)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetValue(400)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			ec:RegisterEffect(e2)
		end
	end
end
-- 装备限制函数，限制该装备卡只能装备给作为对象的怪兽
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
