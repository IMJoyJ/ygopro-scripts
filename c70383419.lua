--召喚獣ベイバロン
-- 效果：
-- 「阿莱斯特」怪兽＋光·地属性怪兽
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。从卡组把1只「人工神灵 维拉卡姆」或1张「魔法名-「新世界之始」」加入手卡。那之后，可以从自己或对方的墓地把1只怪兽除外。
-- ②：把墓地的这张卡除外，以自己场上1只融合怪兽为对象才能发动。对方场上的全部怪兽的攻击力直到回合结束时下降作为对象的怪兽的攻击力数值。
local s,id,o=GetID()
-- 初始化函数，注册融合召唤手续、特殊召唤时的检索除外效果以及墓地除外的攻击力下降效果
function s.initial_effect(c)
	-- 将「人工神灵 维拉卡姆」和「魔法名-「新世界之始」」记录为此卡的关联卡片
	aux.AddCodeList(c,10673071,86319972)
	c:EnableReviveLimit()
	-- 添加融合召唤素材：1只「阿莱斯特」怪兽和1只光属性或地属性的怪兽
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1e1),aux.FilterBoolFunction(Card.IsFusionAttribute,ATTRIBUTE_LIGHT+ATTRIBUTE_EARTH),true)
	-- ①：这张卡特殊召唤的场合才能发动。从卡组把1只「人工神灵 维拉卡姆」或1张「魔法名-「新世界之始」」加入手卡。那之后，可以从自己或对方的墓地把1只怪兽除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索效果"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_REMOVE+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己场上1只融合怪兽为对象才能发动。对方场上的全部怪兽的攻击力直到回合结束时下降作为对象的怪兽的攻击力数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"改变攻击力"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 把墓地的这张卡除外作为效果发动的Cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
-- 检索卡片的过滤函数：卡组中的「人工神灵 维拉卡姆」或「魔法名-「新世界之始」」
function s.thfilter(c)
	return c:IsCode(10673071,86319972) and c:IsAbleToHand()
end
-- 效果①的发动检测与效果分类注册函数
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的卡组中是否存在可以检索的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置当前处理的操作信息为：从自己卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 除外卡片的过滤函数：墓地的怪兽
function s.rmfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 效果①的效果处理执行函数
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示请选择要加入手牌的卡的系统提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只「人工神灵 维拉卡姆」或1张「魔法名-「新世界之始」」
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
		-- 检查双方墓地是否存在可以被除外的怪兽
		if Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.rmfilter),tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil)
			-- 让玩家选择是否执行墓地除外的后续效果
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把卡除外？"
			-- 显示请选择要除外的卡的系统提示
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
			-- 玩家从双方墓地选择1只怪兽
			local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.rmfilter),tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
			if sg:GetCount()>0 then
				-- 中断当前效果，使后续的除外处理与前面的检索处理视为不同时处理
				Duel.BreakEffect()
				-- 显示被选择除外怪兽的选中动画
				Duel.HintSelection(sg)
				-- 将选择的怪兽除外
				Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
			end
		end
	end
end
-- 作为对象融合怪兽的过滤函数：自己场上表侧表示且攻击力不为0的融合怪兽
function s.atkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and not c:IsAttack(0)
end
-- 效果②的发动检测与目标选择函数
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.atkfilter(chkc) end
	-- 检查自己场上是否存在可以作为对象的融合怪兽
	if chk==0 then return Duel.IsExistingTarget(s.atkfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在表侧表示的怪兽
		and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 显示请选择表侧表示的卡的系统提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只融合怪兽作为对象
	Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果②的效果处理执行函数
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取选定的融合怪兽对象
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToChain() or not tc:IsFaceup() then return end
	-- 获取对方场上表侧表示的所有怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		local atkd=tc:GetAttack()
		-- 遍历所有需要降低攻击力的对方怪兽
		for sc in aux.Next(g) do
			-- 对方场上的全部怪兽的攻击力直到回合结束时下降作为对象的怪兽的攻击力数值。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(-atkd)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			sc:RegisterEffect(e1)
		end
	end
end
