--ブレインコントローラー
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「洗脑」加入手卡。
-- ②：自己把基本分支付的场合，以场上1只表侧表示怪兽为对象，宣言1～8的任意等级才能发动。那只怪兽的等级变成宣言的等级。
-- ③：这张卡作为同调素材送去墓地的场合才能发动。这张卡效果无效在对方场上守备表示特殊召唤。
local s,id,o=GetID()
-- 初始化函数：登记「洗脑」的关联卡名，然后创建并注册①检索效果、②等级变更效果、③特殊召唤效果，三个效果均为1回合各能使用1次。
function s.initial_effect(c)
	-- 将卡号87910978（「洗脑」）登记为本卡的关联卡名，便于检索和识别。
	aux.AddCodeList(c,87910978)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「洗脑」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索效果"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：自己把基本分支付的场合，以场上1只表侧表示怪兽为对象，宣言1～8的任意等级才能发动。那只怪兽的等级变成宣言的等级。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PAY_LPCOST)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.lvcon)
	e3:SetTarget(s.lvtg)
	e3:SetOperation(s.lvop)
	c:RegisterEffect(e3)
	-- ③：这张卡作为同调素材送去墓地的场合才能发动。这张卡效果无效在对方场上守备表示特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_BE_MATERIAL)
	e4:SetCountLimit(1,id+o*2)
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
-- 定义①效果的检索过滤条件：卡名为「洗脑」且能够加入手卡。
function s.thfilter(c)
	return c:IsCode(87910978) and c:IsAbleToHand()
end
-- ①效果的Target函数：在发动时确认卡组存在可检索的「洗脑」，并向系统登记“从卡组加入手卡”的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检测：确认卡组中存在至少1张符合条件的「洗脑」。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向系统登记本次效果将执行“从卡组把1张卡加入手卡”的操作信息，用于后续连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：从卡组选择1张「洗脑」加入持有者手卡，并展示给对方确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要加入手牌的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选1张满足检索条件的「洗脑」。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的「洗脑」加入手卡（nil表示加入持有者手卡），原因记为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果的发动条件：自己支付基本分的场合才能发动。
function s.lvcon(e,tp,eg,ep,ev,re,r,rp)
	return tp==ep
end
-- 定义②效果的对象过滤器：场上表侧表示且等级不低于1的怪兽；若传入lv，则排除等级与lv相同的怪兽。
function s.lvfilter(c,lv)
	return c:IsFaceup() and c:IsLevelAbove(1) and (not lv or not c:IsLevel(lv))
end
-- ②效果的Target函数：取场上1只表侧表示怪兽为对象，宣言1～8的任意等级并保存，供效果处理时使用。
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.lvfilter(chkc,e:GetLabel()) end
	-- 发动条件检测：场上存在1只以上可选的表侧表示怪兽作为对象。
	if chk==0 then return Duel.IsExistingTarget(s.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 显示“请选择效果的对象”的目标选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上1只表侧表示且等级不低于1的怪兽作为效果对象，并登记为连锁对象。
	local g=Duel.SelectTarget(tp,s.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	local lv=g:GetFirst():GetLevel()
	-- 显示“请选择要改变的等级”的宣言提示。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))  --"请选择要改变的等级"
	-- 让玩家宣言1～8的任意等级，并将宣言值存入效果标签，供处理阶段使用。
	e:SetLabel(Duel.AnnounceLevel(tp,1,8,lv))
end
-- ②效果处理：将对象怪兽的等级变成宣言等级；若对象合法则给它附加一个不可无效的等级变更效果。
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得该效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	local label=e:GetLabel()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) and tc:IsLevelAbove(1) and not tc:IsLevel(label) then
		-- 那只怪兽的等级变成宣言的等级。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- ③效果的发动条件：这张卡作为同调素材被送去墓地的场合才能发动。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- ③效果的Target函数：确认对方场上有可用怪兽区且这张卡能被特殊召唤到对方场上，并登记特殊召唤操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检测：对方场上有空余怪兽区，且这张卡能够以表侧守备表示特殊召唤到对方场上。
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,1-tp) end
	-- 向系统登记本次效果将特殊召唤这张卡到对方场上的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ③效果处理：若这张卡仍可特殊召唤，则将其表侧守备表示特殊召唤到对方场上，并附加“效果无效”与“效果无效化”状态。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 特殊召唤前检查：这张卡仍与当前连锁相关，且其墓地特殊召唤不受王家长眠之谷等效果妨碍。
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c)
		-- 执行特殊召唤步骤：将这张卡以表侧守备表示特殊召唤到对方场上，成功后继续附加无效化效果。
		and Duel.SpecialSummonStep(c,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE) then
		-- 这张卡效果无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 这张卡效果无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
	end
	-- 宣告特殊召唤步骤完成，结束特殊召唤处理。
	Duel.SpecialSummonComplete()
end
