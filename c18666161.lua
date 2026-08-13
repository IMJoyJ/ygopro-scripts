--デスピアン・プロスケニオン
-- 效果：
-- 「死狱乡」怪兽＋光属性怪兽＋暗属性怪兽
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段，以对方墓地1只融合·同调·超量·连接怪兽为对象才能发动。那只怪兽除外或在自己场上特殊召唤。
-- ②：这张卡战斗破坏对方怪兽时才能发动。给与对方那只怪兽的原本攻击力和原本守备力之内较高方数值的伤害。
function c18666161.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：需要「死狱乡」怪兽1只、光属性怪兽1只、暗属性怪兽1只作为融合素材（光/暗素材分别由下方过滤函数判定）
	aux.AddFusionProcMix(c,false,true,aux.FilterBoolFunction(Card.IsFusionSetCard,0x164),c18666161.matfilter1,c18666161.matfilter2,nil)
	-- ①：自己·对方的主要阶段，以对方墓地1只融合·同调·超量·连接怪兽为对象才能发动。那只怪兽除外或在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18666161,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCountLimit(1,18666161)
	e1:SetCondition(c18666161.effcon)
	e1:SetTarget(c18666161.efftg)
	e1:SetOperation(c18666161.effop)
	c:RegisterEffect(e1)
	-- ②：这张卡战斗破坏对方怪兽时才能发动。给与对方那只怪兽的原本攻击力和原本守备力之内较高方数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(18666161,1))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCountLimit(1,18666162)
	-- 设置效果②的发动条件：自身与对方怪兽进行战斗并将其战斗破坏（aux.bdocon 判定本卡参与战斗且攻击对象为对方怪兽）。
	e2:SetCondition(aux.bdocon)
	e2:SetTarget(c18666161.damtg)
	e2:SetOperation(c18666161.damop)
	c:RegisterEffect(e2)
end
-- 素材过滤器1：融合素材中须包含1只光属性怪兽（用于融合召唤判定）。
function c18666161.matfilter1(c)
	return c:IsFusionAttribute(ATTRIBUTE_LIGHT)
end
-- 素材过滤器2：融合素材中须包含1只暗属性怪兽（用于融合召唤判定）。
function c18666161.matfilter2(c)
	return c:IsFusionAttribute(ATTRIBUTE_DARK)
end
-- 效果①的发动条件：当前阶段为主要阶段1或主要阶段2（即自己或对方的主要阶段）。
function c18666161.effcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段并存入局部变量 ph，用于后续判断是否为主要阶段。
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
-- 效果①的对象过滤器：对方墓地中满足以下条件的怪兽——属于融合·同调·超量·连接怪兽之一，且（可以被除外，或当我方场上有空位且可被特殊召唤时）可被选为目标。
function c18666161.rmfilter(c,e,tp,check)
	return c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK)
		and (c:IsAbleToRemove() or check and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 效果①的发动目标选择函数：首先检查是否存在合法对象；若存在，则让玩家从对方墓地选择1只符合条件的怪兽作为对象，并登记为连锁对象。
function c18666161.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查自己场上是否有可用的主要怪兽区域空格，结果存入 check，用于决定能否选择特殊召唤路线。
	local check=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_GRAVE) and c18666161.rmfilter(chkc,e,tp,check) end
	-- 效果发动合法性判定：确认对方墓地中是否存在至少1只满足 rmfilter 条件且可成为效果对象的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c18666161.rmfilter,tp,0,LOCATION_GRAVE,1,nil,e,tp,check) end
	-- 给发动者发送选择卡片对象的提示文字（HINTMSG_TARGET 表示要求选择效果对象）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让发动者从对方墓地选择1只符合 rmfilter 条件的怪兽，并设置为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,c18666161.rmfilter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp,check)
end
-- 效果①处理时的实际操作：取得对象怪兽；若仍与效果关联且未被王家长眠之谷无效，则根据能否特殊召唤及玩家选择，将其特殊召唤到自己场上，否则将其除外。
function c18666161.effop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的第一个（唯一）对象怪兽，保存至局部变量 tc。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 若对象怪兽受到王家长眠之谷影响，则使本次效果被无效并终止处理（不能对墓地怪兽进行除外/特殊召唤）。
		if aux.NecroValleyNegateCheck(tc) then return end
		-- 判断自己场上是否有可用的怪兽区域空格，并且对象怪兽是否可以被特殊召唤（同时检查召唤条件和苏生限制）。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 进一步判断：若对象怪兽不能被除外，则只能选择特殊召唤；若可被除外，则让玩家在除外（1192）与特殊召唤（1152）之间选择，选后者时执行特殊召唤。
			and (not tc:IsAbleToRemove() or Duel.SelectOption(tp,1192,1152)==1) then
			-- 将对象怪兽以表侧表示特殊召唤到发动者自己场上。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		else
			-- 将对象怪兽以表侧表示除外（处理除外效果）。
			Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		end
	end
end
-- 效果②的发动前处理：取被战斗破坏的对方怪兽，计算其原本攻击力与原本守备力中的较高者作为伤害值，并设置给与对方伤害的对象与数值；若伤害值为0则不能发动。
function c18666161.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	local dam=bc:GetBaseAttack()
	if bc:GetBaseAttack()<bc:GetBaseDefense() then dam=bc:GetBaseDefense() end
	if chk==0 then return dam>0 end
	-- 设置效果对象玩家为对方玩家（1-tp），即伤害的承受者。
	Duel.SetTargetPlayer(1-tp)
	-- 设置效果的对象参数为计算出的伤害值 dam，以供后续处理使用。
	Duel.SetTargetParam(dam)
	-- 向连锁系统登记本次操作为伤害效果，伤害对象为对方玩家，伤害值为 dam，便于其他卡效果响应。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 效果②的伤害处理：从连锁信息中取出登记的对象玩家与伤害值，并给与对方玩家伤害。
function c18666161.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中登记的效果对象玩家 p 和对象参数 d（即伤害数值）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给玩家 p 造成 d 点效果伤害（伤害来源为本卡效果）。
	Duel.Damage(p,d,REASON_EFFECT)
end
