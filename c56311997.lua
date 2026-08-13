--GMX－ALLOS
-- 效果：
-- 「基因组混合」怪兽＋恐龙族怪兽
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：每次对方把怪兽召唤·特殊召唤，自己回复200基本分。
-- ②：以自己的墓地·除外状态的1只「基因组混合」怪兽或恐龙族怪兽为对象才能发动（这个效果发动的回合，这张卡不能攻击）。那只怪兽特殊召唤。
-- ③：这张卡和对方怪兽进行战斗的伤害步骤开始时才能发动。那只怪兽破坏。
local s,id,o=GetID()
-- 初始化卡片效果：设置苏生限制和融合召唤手续，注册①的回复基本分永续效果（召唤·特殊召唤成功时各一个）、②的墓地·除外怪兽特殊召唤起动效果、③的战斗伤害步骤开始时破坏对方怪兽的诱发效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：以1只「基因组混合」怪兽和1只恐龙族怪兽各1只为融合素材
	aux.AddFusionProcFun2(c,s.matfilter1,s.matfilter2,true)
	-- ①：每次对方把怪兽召唤·特殊召唤，自己回复200基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.reccon)
	e1:SetOperation(s.recop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：以自己的墓地·除外状态的1只「基因组混合」怪兽或恐龙族怪兽为对象才能发动（这个效果发动的回合，这张卡不能攻击）。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	-- ③：这张卡和对方怪兽进行战斗的伤害步骤开始时才能发动。那只怪兽破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"破坏对方怪兽"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_START)
	e4:SetCountLimit(1,id+o)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
end
-- 融合素材过滤函数1：判断怪兽是否为「基因组混合」系列怪兽
function s.matfilter1(c)
	return c:IsFusionSetCard(0x1dd)
end
-- 融合素材过滤函数2：判断怪兽是否为恐龙族怪兽
function s.matfilter2(c)
	return c:IsRace(RACE_DINOSAUR)
end
-- 过滤函数：判断该怪兽是否为由指定玩家召唤·特殊召唤的怪兽
function s.cfilter(c,tp)
	return c:IsSummonPlayer(tp)
end
-- ①效果的发动条件：本次召唤·特殊召唤成功的怪兽中存在对方玩家召唤的怪兽
function s.reccon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,1-tp)
end
-- ①效果的处理：显示卡片提示动画，然后让自己回复200基本分
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示这张卡的发动动画，向双方提示效果正在处理
	Duel.Hint(HINT_CARD,0,id)
	-- 让自己回复200基本分
	Duel.Recover(tp,200,REASON_EFFECT)
end
-- ②效果的发动代价：要求这张卡本回合尚未攻击宣言，并给这张卡赋予本回合不能攻击的誓约效果
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetAttackAnnouncedCount()==0 end
	-- 这个效果发动的回合，这张卡不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1,true)
end
-- 特殊召唤对象的过滤函数：在自己墓地·除外状态表侧表示的「基因组混合」怪兽或恐龙族怪兽中，可以被特殊召唤的卡
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and (c:IsSetCard(0x1dd) or c:IsRace(RACE_DINOSAUR)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的对象选择：确认自己的主要怪兽区有空位，且自己的墓地·除外状态存在可以成为对象的符合条件的怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 检查自己的主要怪兽区是否有可用的空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的墓地·除外状态是否存在1只以上可以成为效果对象的「基因组混合」或恐龙族怪兽
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 向自己发送选卡提示：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让自己选择1只自己墓地·除外状态的符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置操作信息：本次连锁将对那1只对象怪兽进行特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果的处理：取得对象怪兽，若其仍与本连锁相关且不受王家长眠之谷影响，则将其攻击表示特殊召唤到自己场上
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的效果对象（第1只）
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍与本连锁相关，且不受王家长眠之谷的影响
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 将对象怪兽以表侧攻击表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ③效果的目标设定：取得这张卡进行战斗的对方怪兽，确认其为对方控制的怪兽，并设置破坏的操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetHandler():GetBattleTarget()
	if chk==0 then return tc and tc:IsControler(1-tp) end
	-- 设置操作信息：本次连锁将破坏那只进行战斗的对方怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
end
-- ③效果的处理：取得进行战斗的对方怪兽，若其仍在战斗中且为对方控制的怪兽，则将其破坏
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	if tc:IsRelateToBattle() and tc:IsControler(1-tp) and tc:IsType(TYPE_MONSTER) then
		-- 以效果原因将那只对方怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
