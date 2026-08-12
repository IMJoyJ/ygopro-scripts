--ゴーストリック・ブレイク
-- 效果：
-- ①：自己场上的「鬼计」怪兽1只被战斗或者对方的效果破坏送去自己墓地时，以和破坏的那只怪兽卡名不同的自己墓地2只「鬼计」怪兽为对象才能发动。那些怪兽里侧守备表示特殊召唤。
function c80802524.initial_effect(c)
	-- ①：自己场上的「鬼计」怪兽1只被战斗或者对方的效果破坏送去自己墓地时，以和破坏的那只怪兽卡名不同的自己墓地2只「鬼计」怪兽为对象才能发动。那些怪兽里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c80802524.condition)
	e1:SetTarget(c80802524.target)
	e1:SetOperation(c80802524.activate)
	c:RegisterEffect(e1)
end
-- 判定是否满足“自己场上的1只表侧表示「鬼计」怪兽被战斗或对方的效果破坏送去自己墓地”的发动条件，并记录该怪兽的卡名
function c80802524.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if eg:GetCount()==1 and tc:IsReason(REASON_DESTROY) and (tc:IsReason(REASON_BATTLE) or rp==1-tp and tc:IsReason(REASON_EFFECT))
		and tc:IsPreviousLocation(LOCATION_MZONE) and tc:IsPreviousControler(tp) and tc:IsSetCard(0x8d) and tc:IsPreviousPosition(POS_FACEUP) then
		e:SetLabel(tc:GetCode())
		return true
	else return false end
end
-- 过滤墓地中与被破坏怪兽卡名不同、且可以里侧守备表示特殊召唤的「鬼计」怪兽
function c80802524.filter(c,e,tp,code)
	return c:IsSetCard(0x8d) and not c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 效果发动时的对象选择与可行性检测，确认墓地中是否存在2只符合条件的「鬼计」怪兽，且自己场上有2个以上的可用怪兽区域
function c80802524.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c80802524.filter(chkc,e,tp,e:GetLabel()) end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己场上的主要怪兽区域空位数是否大于1（因为需要同时特殊召唤2只怪兽）
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查自己墓地是否存在至少2只满足过滤条件的「鬼计」怪兽
		and Duel.IsExistingTarget(c80802524.filter,tp,LOCATION_GRAVE,0,2,nil,e,tp,e:GetLabel()) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地2只符合条件的「鬼计」怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c80802524.filter,tp,LOCATION_GRAVE,0,2,2,nil,e,tp,e:GetLabel())
	-- 设置效果处理信息，表示该效果包含特殊召唤2只目标怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,0,0)
end
-- 效果处理的执行函数，将作为对象的怪兽在自己场上里侧守备表示特殊召唤，并让对方确认
function c80802524.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为效果对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 获取自己场上可用的主要怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if sg:GetCount()==0 or ft<=0 or (sg:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then return end
	if ft<sg:GetCount() then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		sg=sg:FilterSelect(tp,c80802524.filter,ft,ft,nil,e,tp,e:GetLabel())
	end
	if sg:GetCount()>0 then
		-- 将选中的怪兽以里侧守备表示特殊召唤到自己场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 让对方玩家确认里侧表示特殊召唤的怪兽
		Duel.ConfirmCards(1-tp,sg)
	end
end
