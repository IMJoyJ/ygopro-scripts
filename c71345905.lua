--RDM－ヌメロン・フォール
-- 效果：
-- 选择自己场上1只名字带有「希望皇 霍普」的怪兽才能发动。比选择的怪兽阶级低的1只名字带有「希望皇 霍普」的怪兽在选择的自己怪兽上面重叠当作超量召唤从额外卡组特殊召唤。这个效果超量召唤的怪兽得到以下效果。
-- ●这张卡和对方怪兽进行战斗的场合，只在战斗阶段内那只对方怪兽的效果无效化。
function c71345905.initial_effect(c)
	-- 选择自己场上1只名字带有「希望皇 霍普」的怪兽才能发动。比选择的怪兽阶级低的1只名字带有「希望皇 霍普」的怪兽在选择的自己怪兽上面重叠当作超量召唤从额外卡组特殊召唤。这个效果超量召唤的怪兽得到以下效果。●这张卡和对方怪兽进行战斗的场合，只在战斗阶段内那只对方怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c71345905.target)
	e1:SetOperation(c71345905.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己场上表侧表示、阶级大于1且可以作为超量素材的「希望皇 霍普」怪兽
function c71345905.filter1(c,e,tp)
	local rk=c:GetRank()
	return rk>1 and c:IsFaceup() and c:IsSetCard(0x107f)
		-- 检查额外卡组是否存在满足特殊召唤条件的、阶级比该怪兽低的「希望皇 霍普」怪兽
		and Duel.IsExistingMatchingCard(c71345905.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,rk)
		-- 检查该怪兽是否满足必须作为超量素材的限制条件
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
end
-- 过滤额外卡组中阶级比目标怪兽低、且能以目标怪兽为素材进行超量召唤的「希望皇 霍普」怪兽
function c71345905.filter2(c,e,tp,mc,rk)
	return c:IsRankBelow(rk-1) and c:IsSetCard(0x107f) and mc:IsCanBeXyzMaterial(c)
		-- 检查该怪兽是否能以超量召唤的形式特殊召唤，且额外怪兽区域或主要怪兽区域有足够的空位
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 效果发动时的对象选择与操作准备阶段，确认场上存在合法的目标怪兽并将其设为效果对象
function c71345905.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c71345905.filter1(chkc,e,tp) end
	-- 检查自己场上是否存在可以作为此效果对象的「希望皇 霍普」怪兽
	if chk==0 then return Duel.IsExistingTarget(c71345905.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择要作为效果对象的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只满足条件的「希望皇 霍普」怪兽作为效果对象
	Duel.SelectTarget(tp,c71345905.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置连锁信息，表明此效果包含从额外卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理阶段，将选择的怪兽作为素材，从额外卡组超量召唤阶级较低的「希望皇 霍普」怪兽，并赋予其战斗时使对方怪兽效果无效的效果
function c71345905.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在效果发动时选择的作为对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 再次检查该对象怪兽在效果处理时是否仍满足必须作为超量素材的限制
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只阶级比对象怪兽低的「希望皇 霍普」怪兽
	local g=Duel.SelectMatchingCard(tp,c71345905.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetRank())
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			-- 将原对象怪兽持有的超量素材转移到新召唤的怪兽旗下
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		-- 将原对象怪兽重叠在新召唤的怪兽下方，作为其超量素材
		Duel.Overlay(sc,Group.FromCards(tc))
		-- 将新怪兽以表侧表示特殊召唤，此特殊召唤视为超量召唤
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
		-- ●这张卡和对方怪兽进行战斗的场合，只在战斗阶段内那只对方怪兽的效果无效化。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_ATTACK_ANNOUNCE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetOperation(c71345905.disop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		sc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EVENT_BE_BATTLE_TARGET)
		sc:RegisterEffect(e2)
		-- 只在战斗阶段内那只对方怪兽的效果无效化。
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_DISABLE)
		e3:SetRange(LOCATION_MZONE)
		e3:SetTargetRange(0,LOCATION_MZONE)
		e3:SetTarget(c71345905.distg)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		sc:RegisterEffect(e3)
		local e4=e3:Clone()
		e4:SetCode(EFFECT_DISABLE_EFFECT)
		e4:SetValue(RESET_TURN_SET)
		sc:RegisterEffect(e4)
		sc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(71345905,0))  --"「降阶魔法-源数之落」效果适用中"
	end
end
-- 当该怪兽进行攻击宣言或被选为攻击对象时，给与之战斗的对方怪兽添加用于标记无效化的Flag，并立即刷新场上卡片状态
function c71345905.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if bc then
		bc:RegisterFlagEffect(71345905,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
		-- 立即刷新场上卡片的状态，使无效化效果即时生效
		Duel.AdjustInstantly(e:GetHandler())
	end
end
-- 过滤出带有特定Flag（即正在与该怪兽进行战斗）的对方怪兽，作为无效化效果的适用对象
function c71345905.distg(e,c)
	return c:GetFlagEffect(71345905)~=0
end
