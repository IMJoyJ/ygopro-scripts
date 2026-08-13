--デコード・トーカー・ヒートソウル
-- 效果：
-- 属性不同的电子界族怪兽2只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的攻击力上升这张卡所连接区的怪兽数量×500。
-- ②：自己·对方回合，支付1000基本分才能发动。自己抽1张。自己基本分是2000以下的场合，可以再让以下效果适用。
-- ●场上的这张卡除外，除「解码语者·炽热之魂」外的1只连接3以下的电子界族怪兽从额外卡组特殊召唤。
function c61245672.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续：使用2～3只属性不同的电子界族怪兽作为连接素材（对应召唤条件“属性不同的电子界族怪兽2只以上”）。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_CYBERSE),2,3,c61245672.lcheck)
	-- ①：这张卡的攻击力上升这张卡所连接区的怪兽数量×500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c61245672.atkval)
	c:RegisterEffect(e1)
	-- 对应②效果：这个卡名的②的效果1回合只能使用1次。②：自己·对方回合，支付1000基本分才能发动。自己抽1张。自己基本分是2000以下的场合，可以再让以下效果适用。●场上的这张卡除外，除「解码语者·炽热之魂」外的1只连接3以下的电子界族怪兽从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(61245672,0))
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMING_MAIN_END+TIMING_END_PHASE)
	e2:SetCountLimit(1,61245672)
	e2:SetCost(c61245672.drcost)
	e2:SetTarget(c61245672.drtg)
	e2:SetOperation(c61245672.drop)
	c:RegisterEffect(e2)
end
-- 连接素材合法性检查：素材组中各怪兽的连接属性种类数等于素材数量，即所有素材的属性均不相同。
function c61245672.lcheck(g)
	return g:GetClassCount(Card.GetLinkAttribute)==g:GetCount()
end
-- 攻击力上升值的计算：这张卡所连接区的怪兽数量乘以500。
function c61245672.atkval(e,c)
	return c:GetLinkedGroupCount()*500
end
-- ②效果的发动代价：检查并支付1000基本分。
function c61245672.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性检查阶段，返回玩家tp能否支付1000基本分作为代价。
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 实际扣除玩家tp的1000基本分，作为发动费用。
	Duel.PayLPCost(tp,1000)
end
-- 筛选可特殊召唤的额外卡组怪兽：满足电子界族、连接怪兽、连接3以下、不是「解码语者·炽热之魂」自身、能够被效果特殊召唤，并且除外自身后从额外卡组特殊召唤时有可用区域。
function c61245672.cfilter(c,e,tp,mc)
	return c:IsRace(RACE_CYBERSE) and c:IsType(TYPE_LINK) and c:IsLinkBelow(3) and not c:IsCode(61245672)
		-- 追加判定：该怪兽能够被效果特殊召唤，且除外自身作为释放区域后，从额外卡组特殊召唤时仍存在可用的怪兽区域。
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- ②效果的发动目标处理：将目标玩家设定为tp、抽卡数设为1，并登记抽卡操作信息。
function c61245672.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动合法性检查阶段，确认玩家tp可以抽1张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将当前连锁的目标玩家设置为tp，表示由tp抽卡。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的目标参数设置为1，表示抽卡数量为1。
	Duel.SetTargetParam(1)
	-- 登记本次连锁的操作信息：效果包含抽卡分类，抽卡玩家为tp，预计抽1张卡，用于相关卡片的诱发检测。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②效果的实际处理：抽1张卡；若抽卡成功且自己LP在2000以下，且本卡仍关联此效果且能被除外，且额外卡组有符合条件的怪兽，则询问玩家是否特殊召唤；若同意则除外本卡，从额外卡组特殊召唤1只符合条件的电子界族连接怪兽。
function c61245672.drop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取出连锁中登记的目标玩家p和抽卡张数d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡；若抽卡成功，且自己LP≤2000，且本卡仍与此效果相关且可被除外，则继续后续特殊召唤分支。
	if Duel.Draw(p,d,REASON_EFFECT)~=0 and Duel.GetLP(tp)<=2000 and c:IsRelateToEffect(e) and c:IsAbleToRemove()
		-- 检查额外卡组是否存在至少1只满足cfilter条件的怪兽（电子界族、连接3以下、不是本卡且可特殊召唤）。
		and Duel.IsExistingMatchingCard(c61245672.cfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
		-- 询问玩家是否发动“再让以下效果适用”的特殊召唤分支（显示“是否特殊召唤？”）。
		and Duel.SelectYesNo(tp,aux.Stringid(61245672,1)) then  --"是否特殊召唤？"
		-- 中断当前效果的处理，使后续的除外与特殊召唤视为不同时处理，防止错过时点。
		Duel.BreakEffect()
		-- 将场上的这张卡表侧表示除外；若除外成功且该卡进入除外状态，则继续执行特殊召唤。
		if Duel.Remove(c,POS_FACEUP,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_REMOVED) then
			-- 从额外卡组选择1只满足条件的电子界族连接怪兽（连接3以下且不是「解码语者·炽热之魂」）。
			local g=Duel.SelectMatchingCard(tp,c61245672.cfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
			-- 将选择的怪兽以表侧表示特殊召唤到自己的场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
