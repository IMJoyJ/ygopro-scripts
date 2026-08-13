--ギミック・パペット－ボム・エッグ
-- 效果：
-- 自己的主要阶段时可以从手卡丢弃1只名字带有「机关傀儡」的怪兽，从以下效果选择1个发动。「机关傀儡-炸蛋头」的效果1回合只能使用1次。
-- ●给与对方基本分800分伤害。
-- ●这张卡的等级直到结束阶段时变成8星。
function c20032555.initial_effect(c)
	-- 对应效果原文：“自己的主要阶段时可以从手卡丢弃1只名字带有「机关傀儡」的怪兽，从以下效果选择1个发动。「机关傀儡-炸蛋头」的效果1回合只能使用1次。”
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20032555,0))  --"选择效果发动"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,20032555)
	e1:SetTarget(c20032555.efftg)
	e1:SetOperation(c20032555.effop)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查手牌怪兽是否是卡名含有「机关傀儡」的怪兽卡，并且可以作为代价丢弃。
function c20032555.cfilter(c)
	return c:IsSetCard(0x1083) and c:IsType(TYPE_MONSTER) and c:IsDiscardable()
end
-- 效果发动时处理：先确认己方手牌存在可丢弃的「机关傀儡」怪兽；然后作为代价丢弃1只符合条件的「机关傀儡」怪兽；再根据这张卡的当前等级选择给玩家提供的选项（等级为8时只有伤害选项，否则额外提供变8星选项），把玩家选择的选项存入标签，并据此设置效果类别和伤害操作信息。
function c20032555.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动判定阶段检查：己方手牌中是否存在至少1只满足c20032555.cfilter条件的「机关傀儡」怪兽，可以作为丢弃代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c20032555.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 由己方玩家从手牌选择1只满足c20032555.cfilter条件的怪兽，以代价并丢弃的理由送入墓地。
	Duel.DiscardHand(tp,c20032555.cfilter,1,1,REASON_COST+REASON_DISCARD)
	local opt=0
	if e:GetHandler():IsLevel(8) then
		-- 当这张卡当前等级为8时，只向玩家显示“给与对方基本分800分伤害”这一个选项。
		opt=Duel.SelectOption(tp,aux.Stringid(20032555,1))  --"给与对方基本分800分伤害"
	else
		-- 当这张卡当前等级不为8时，向玩家显示“给与对方基本分800分伤害”和“这张卡的等级直到结束阶段时变成8星”两个选项。
		opt=Duel.SelectOption(tp,aux.Stringid(20032555,1),aux.Stringid(20032555,2))  --"给与对方基本分800分伤害/这张卡的等级直到结束阶段时变成8星"
	end
	e:SetLabel(opt)
	if opt==0 then
		e:SetCategory(CATEGORY_DAMAGE)
		-- 登记本次效果处理中会给对方造成800点伤害的操作信息，用于连锁和效果发动判定等。
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
	else
		e:SetCategory(0)
	end
end
-- 效果处理时根据目标阶段记录的选择：若选择0则给与对方800点伤害；否则为这张卡创建一个持续到结束阶段的等级变更效果，将其等级变成8星。
function c20032555.effop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		-- 以效果伤害的方式，向对方玩家造成800点基本分伤害。
		Duel.Damage(1-tp,800,REASON_EFFECT)
	else
		-- 对应效果原文：“●这张卡的等级直到结束阶段时变成8星。”
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(8)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e:GetHandler():RegisterEffect(e1)
	end
end
