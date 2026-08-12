--クリボーン
-- 效果：
-- ①：自己·对方的战斗阶段结束时把这张卡从手卡丢弃，以这个回合被战斗破坏送去自己墓地的1只怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：对方怪兽的攻击宣言时，把墓地的这张卡除外，以自己墓地的「栗子球」怪兽任意数量为对象才能发动。那些怪兽特殊召唤。
function c78355370.initial_effect(c)
	-- ①：自己·对方的战斗阶段结束时把这张卡从手卡丢弃，以这个回合被战斗破坏送去自己墓地的1只怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(78355370,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c78355370.spcost1)
	e1:SetTarget(c78355370.sptg1)
	e1:SetOperation(c78355370.spop1)
	c:RegisterEffect(e1)
	-- ②：对方怪兽的攻击宣言时，把墓地的这张卡除外，以自己墓地的「栗子球」怪兽任意数量为对象才能发动。那些怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(78355370,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c78355370.spcon2)
	-- 把墓地的这张卡除外作为发动的代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c78355370.sptg2)
	e2:SetOperation(c78355370.spop2)
	c:RegisterEffect(e2)
end
-- 效果①的发动代价处理函数
function c78355370.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将自身作为代价送去墓地（丢弃）
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 过滤条件：本回合被战斗破坏送去自己墓地且可以特殊召唤的怪兽
function c78355370.spfilter1(c,e,tp,tid)
	return c:GetTurnID()==tid and bit.band(c:GetReason(),REASON_BATTLE)~=0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备与目标选择
function c78355370.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前的回合数
	local tid=Duel.GetTurnCount()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c78355370.spfilter1(chkc,e,tp,tid) end
	-- 发动条件：自己场上有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且自己墓地存在至少1只满足条件的怪兽可以作为对象
		and Duel.IsExistingTarget(c78355370.spfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp,tid) end
	-- 设置选择特殊召唤卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择1只满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c78355370.spfilter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,tid)
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的效果处理函数
function c78355370.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的发动条件判断函数
function c78355370.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断进行攻击宣言的怪兽是否由对方控制
	return Duel.GetAttacker():GetControler()~=tp
end
-- 过滤条件：自己墓地的「栗子球」怪兽且可以特殊召唤
function c78355370.spfilter2(c,e,tp)
	return c:IsSetCard(0xa4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsType(TYPE_MONSTER)
end
-- 效果②的发动准备与目标选择
function c78355370.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c78355370.spfilter2(chkc,e,tp) end
	-- 发动条件：自己场上有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且自己墓地存在至少1只满足条件的「栗子球」怪兽（排除自身）可以作为对象
		and Duel.IsExistingTarget(c78355370.spfilter2,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 设置选择特殊召唤卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择任意数量（不超过可用怪兽区域数）满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c78355370.spfilter2,tp,LOCATION_GRAVE,0,1,ft,nil,e,tp)
	-- 设置特殊召唤的操作信息，数量为选择的对象数量
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
end
-- 效果②的效果处理函数
function c78355370.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 获取仍与效果相关的对象怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if g:GetCount()>ft then
		-- 设置选择特殊召唤卡片的提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		g=g:Select(tp,ft,ft,nil)
	end
	if g:GetCount()>0 then
		-- 将选择的对象怪兽在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
