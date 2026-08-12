--D-HERO ドミネイトガイ
-- 效果：
-- 「命运英雄」怪兽×3
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。从自己或者对方的卡组上面把5张卡确认，用喜欢的顺序回到卡组上面。
-- ②：这张卡战斗破坏对方怪兽时才能发动。自己从卡组抽1张。
-- ③：融合召唤的这张卡被战斗·效果破坏的场合，以自己墓地3只9星以下的「命运英雄」怪兽为对象才能发动（同名卡最多1张）。那些怪兽特殊召唤。
function c69394324.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤手续：需要3只「命运英雄」怪兽作为融合素材
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0xc008),3,true)
	-- ①：自己主要阶段才能发动。从自己或者对方的卡组上面把5张卡确认，用喜欢的顺序回到卡组上面。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,69394324)
	e1:SetTarget(c69394324.target)
	e1:SetOperation(c69394324.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡战斗破坏对方怪兽时才能发动。自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(69394324,2))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCountLimit(1,69394325)
	-- 设置发动条件：此卡战斗破坏对方怪兽时
	e2:SetCondition(aux.bdocon)
	e2:SetTarget(c69394324.drtg)
	e2:SetOperation(c69394324.drop)
	c:RegisterEffect(e2)
	-- ③：融合召唤的这张卡被战斗·效果破坏的场合，以自己墓地3只9星以下的「命运英雄」怪兽为对象才能发动（同名卡最多1张）。那些怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(69394324,3))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,69394326)
	e3:SetCondition(c69394324.spcon)
	e3:SetTarget(c69394324.sptg)
	e3:SetOperation(c69394324.spop)
	c:RegisterEffect(e3)
end
c69394324.material_setcode=0xc008
-- 效果①（确认卡组）的发动准备与合法性检测函数
function c69394324.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己或对方的卡组上方是否有至少5张卡
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=5 or Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)>=5 end
end
-- 效果①（确认卡组）的效果处理函数
function c69394324.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己卡组的卡片数量是否在5张以上
	local b1=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=5
	-- 检查对方卡组的卡片数量是否在5张以上
	local b2=Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)>=5
	if not b1 and not b2 then return end
	local op=nil
	if b1 and b2 then
		-- 让玩家选择是确认自己卡组还是确认对方卡组
		op=Duel.SelectOption(tp,aux.Stringid(69394324,0),aux.Stringid(69394324,1))  --"确认自己卡组/确认对方卡组"
	elseif b1 then
		-- 在只能确认自己卡组时，让玩家选择确认自己卡组的选项
		op=Duel.SelectOption(tp,aux.Stringid(69394324,0))  --"确认自己卡组"
	else
		-- 在只能确认对方卡组时，让玩家选择确认对方卡组的选项，并将选项索引值加1以匹配后续逻辑
		op=Duel.SelectOption(tp,aux.Stringid(69394324,1))+1  --"确认对方卡组"
	end
	local p=op==0 and tp or 1-tp
	-- 让玩家确认目标玩家卡组最上方的5张卡，并按喜欢的顺序放回卡组最上方
	Duel.SortDecktop(tp,p,5)
end
-- 效果②（抽卡）的发动准备与合法性检测函数
function c69394324.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否可以从卡组抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置效果处理的目标玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置效果处理的抽卡数量参数为1张
	Duel.SetTargetParam(1)
	-- 设置当前连锁的操作信息：自己抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果②（抽卡）的效果处理函数
function c69394324.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行效果：让目标玩家抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 效果③（特殊召唤）的发动条件检测：融合召唤的此卡被战斗或效果破坏
function c69394324.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_FUSION) and bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 过滤满足条件的卡：墓地中9星以下的「命运英雄」怪兽，且可以被特殊召唤并作为效果对象
function c69394324.spfilter(c,e,tp)
	return c:IsSetCard(0xc008) and c:IsLevelBelow(9) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and c:IsCanBeEffectTarget(e)
end
-- 效果③（特殊召唤）的发动准备与合法性检测函数
function c69394324.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c69394324.spfilter(chkc,e,tp) end
	-- 获取自己墓地中所有满足特殊召唤条件的9星以下「命运英雄」怪兽
	local g=Duel.GetMatchingGroup(c69394324.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己场上的主要怪兽区域空位数是否在3个以上
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>=3
		and g:GetClassCount(Card.GetCode)>=3 end
	-- 设置选择卡片时的提示信息为“请选择要特殊召唤的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从可选怪兽中筛选出3只卡名不同的怪兽
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,3,3)
	-- 将选中的3只怪兽设为效果的对象
	Duel.SetTargetCard(sg)
	-- 设置当前连锁的操作信息：特殊召唤这3只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,3,0,0)
end
-- 效果③（特殊召唤）的效果处理函数
function c69394324.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的主要怪兽区域空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取作为效果对象且仍与该效果相关的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if g:GetCount()==0 or (g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then return end
	if g:GetCount()<=ft then
		-- 将这些怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	else
		-- 设置选择卡片时的提示信息为“请选择要特殊召唤的卡”
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,ft,ft,nil)
		-- 将筛选出的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
