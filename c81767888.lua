--烙印の剣
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：从自己墓地把「烙印」魔法·陷阱卡任意数量除外才能发动。除外数量的「冰剑衍生物」（龙族·暗·8星·攻2500/守2000）在自己场上特殊召唤。
-- ②：把墓地的这张卡除外，以自己的除外状态的1只「阿不思的落胤」或者有那个卡名记述的怪兽为对象才能发动。那只怪兽加入手卡。
function c81767888.initial_effect(c)
	-- 注册卡片效果中记载了「阿不思的落胤」的卡片信息
	aux.AddCodeList(c,68468459)
	-- ①：从自己墓地把「烙印」魔法·陷阱卡任意数量除外才能发动。除外数量的「冰剑衍生物」（龙族·暗·8星·攻2500/守2000）在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,81767888)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCost(c81767888.spcost)
	e1:SetTarget(c81767888.sptg)
	e1:SetOperation(c81767888.spop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己的除外状态的1只「阿不思的落胤」或者有那个卡名记述的怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,81767888)
	-- 把墓地的这张卡除外作为发动效果的代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c81767888.thtg)
	e2:SetOperation(c81767888.thop)
	c:RegisterEffect(e2)
end
-- 过滤自己墓地中可以作为代价除外的「烙印」魔法·陷阱卡
function c81767888.costfilter(c)
	return c:IsSetCard(0x15d) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemoveAsCost()
end
-- 效果①的发动代价处理函数，由于需要根据除外数量决定特招数量，在target中进行实际的除外操作，此处仅设置Label标记
function c81767888.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then return true end
end
-- 效果①的发动准备处理函数，检查是否能特招、选择并除外任意数量的「烙印」魔陷、设置特招数量并声明操作信息
function c81767888.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then
		if e:GetLabel()==0 then return false end
		e:SetLabel(0)
		-- 检查自己场上是否有空位，且自己墓地是否存在至少1张可以除外的「烙印」魔法·陷阱卡
		return ft>0 and Duel.IsExistingMatchingCard(c81767888.costfilter,tp,LOCATION_GRAVE,0,1,nil)
			-- 检查玩家是否可以特殊召唤「冰剑衍生物」（龙族·暗·8星·攻2500/守2000）
			and Duel.IsPlayerCanSpecialSummonMonster(tp,81767889,0,TYPES_TOKEN_MONSTER,2500,2000,8,RACE_DRAGON,ATTRIBUTE_DARK)
	end
	e:SetLabel(0)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 给玩家发送“请选择要除外的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1张到可用怪兽区域数量上限张的「烙印」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c81767888.costfilter,tp,LOCATION_GRAVE,0,1,ft,nil)
	-- 将选择的卡表侧表示除外作为发动的代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetLabel(#g)
	-- 设置连锁处理中的操作信息，声明将产生除外卡片数量的衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,#g,0,0)
	-- 设置连锁处理中的操作信息，声明将特殊召唤除外卡片数量的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,#g,0,0)
end
-- 效果①的效果处理函数，在自己场上特殊召唤对应数量的「冰剑衍生物」
function c81767888.spop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	-- 获取当前自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 如果需要特招的数量大于可用区域数量，或者无法特招该衍生物，则不处理效果
	if ct>ft or not Duel.IsPlayerCanSpecialSummonMonster(tp,81767889,0,TYPES_TOKEN_MONSTER,2500,2000,8,RACE_DRAGON,ATTRIBUTE_DARK) then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ct>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	for i=1,ct do
		-- 创建「冰剑衍生物」的卡片数据
		local token=Duel.CreateToken(tp,81767889)
		-- 将衍生物以表侧表示特殊召唤到自己场上的单步处理
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 完成所有怪兽的特殊召唤
	Duel.SpecialSummonComplete()
end
-- 过滤自己除外状态的「阿不思的落胤」或者有该卡名记述的表侧表示怪兽
function c81767888.thfilter(c)
	-- 检查卡片是否为表侧表示、可以加入手牌，且是「阿不思的落胤」或记述了该卡名的怪兽
	return (c:IsCode(68468459) or aux.IsCodeListed(c,68468459) and c:IsType(TYPE_MONSTER)) and c:IsFaceup() and c:IsAbleToHand()
end
-- 效果②的发动准备处理函数，选择自己除外状态的1只符合条件的怪兽作为对象
function c81767888.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c81767888.thfilter(chkc) end
	-- 检查自己除外状态是否存在至少1只符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c81767888.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 给玩家发送“请选择要加入手牌的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己除外状态的1只符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c81767888.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置连锁处理中的操作信息，声明将该对象怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果②的效果处理函数，将作为对象的怪兽加入手牌
function c81767888.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该怪兽加入持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
