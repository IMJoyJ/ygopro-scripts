--魔導皇士 アンプール
-- 效果：
-- 把这张卡以外的自己场上表侧表示存在的1只魔法师族怪兽和自己墓地1张名字带有「魔导书」的卡从游戏中除外才能发动。选择对方场上表侧表示存在的1只怪兽直到结束阶段时得到控制权。「魔导皇士 安普尔」的效果1回合只能使用1次，这个效果发动的回合，这张卡不能攻击。
function c53136004.initial_effect(c)
	-- 把这张卡以外的自己场上表侧表示存在的1只魔法师族怪兽和自己墓地1张名字带有「魔导书」的卡从游戏中除外才能发动。选择对方场上表侧表示存在的1只怪兽直到结束阶段时得到控制权。「魔导皇士 安普尔」的效果1回合只能使用1次，这个效果发动的回合，这张卡不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetDescription(aux.Stringid(53136004,0))  --"获得控制权"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,53136004)
	e1:SetCost(c53136004.cost)
	e1:SetTarget(c53136004.target)
	e1:SetOperation(c53136004.operation)
	c:RegisterEffect(e1)
end
-- 筛选可作为发动代价的魔法师族怪兽：需表侧表示、魔法师族、可作为代价除外，且该卡除外后自己场上仍有可用的怪兽区空格（用于之后获得控制权）。
function c53136004.cfilter1(c,tp)
	-- 判定该怪兽是否满足代价条件：表侧表示、魔法师族、可作为代价除外，且除外后己方怪兽区仍有空格（为后续获得控制权做准备）。
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER) and c:IsAbleToRemoveAsCost() and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
end
-- 筛选墓地中可作为代价的「魔导书」卡：卡名含有「魔导书」字段，且可作为代价除外。
function c53136004.cfilter2(c)
	return c:IsSetCard(0x106e) and c:IsAbleToRemoveAsCost()
end
-- 代价检查：确认本卡本回合尚未进行过攻击宣言，且自己场上存在可除外的魔法师族怪兽、自己墓地存在可除外的「魔导书」卡。
function c53136004.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetAttackAnnouncedCount()==0
		-- 检查自己场上是否存在1张除本卡以外的魔法师族怪兽可作为代价（需满足表侧表示、可除外、除外后仍有空格）。
		and Duel.IsExistingMatchingCard(c53136004.cfilter1,tp,LOCATION_MZONE,0,1,e:GetHandler(),tp)
		-- 检查自己墓地是否存在1张满足条件的「魔导书」卡可作为代价。
		and Duel.IsExistingMatchingCard(c53136004.cfilter2,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给玩家显示选择提示，要求选择要除外的卡（作为发动代价）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己场上选择1张除本卡以外满足条件的魔法师族怪兽作为除外代价。
	local g1=Duel.SelectMatchingCard(tp,c53136004.cfilter1,tp,LOCATION_MZONE,0,1,1,e:GetHandler(),tp)
	-- 再次给玩家显示选择提示，要求选择要除外的卡（作为发动代价）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择1张满足条件的「魔导书」卡作为除外代价。
	local g2=Duel.SelectMatchingCard(tp,c53136004.cfilter2,tp,LOCATION_GRAVE,0,1,1,nil)
	g1:Merge(g2)
	-- 将选择的魔法师族怪兽和「魔导书」卡从游戏中除外，作为发动代价。
	Duel.Remove(g1,POS_FACEUP,REASON_COST)
	-- 这个效果发动的回合，这张卡不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 目标筛选：对方场上的表侧表示怪兽，且其控制权可以改变（忽略怪兽区空格限制）。
function c53136004.filter(c)
	return c:IsFaceup() and c:IsControlerCanBeChanged(true)
end
-- 效果发动时的取对象处理：从对方场上选择1只表侧表示且可改变控制权的怪兽作为对象，并设置操作信息为改变控制权。
function c53136004.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c53136004.filter(chkc) end
	-- 检查对方场上是否存在1只满足条件（表侧表示且可改变控制权）的怪兽可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c53136004.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 给玩家显示选择提示，要求选择要改变控制权的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上1只满足条件的表侧表示怪兽作为效果对象，并建立与连锁的对象关联。
	local g=Duel.SelectTarget(tp,c53136004.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置本次连锁的操作信息：效果分类为改变控制权，对象为选择的怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果处理：获取对象怪兽，若其仍表侧表示且与本效果关联，则获得其控制权直到结束阶段。
function c53136004.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时需要处理的对象卡（即发动时选择的那只对方怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 获得该怪兽的控制权，持续到结束阶段（在结束阶段时重置控制权）。
		Duel.GetControl(tc,tp,PHASE_END,1)
	end
end
