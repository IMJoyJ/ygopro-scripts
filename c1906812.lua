--鉄駆竜スプリンド
-- 效果：
-- 「阿不思的落胤」＋这个回合特殊召唤的效果怪兽
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。自己场上的这张卡的位置向其他的自己的主要怪兽区域移动。那之后，可以把和移动过的这张卡相同纵列的其他的表侧表示卡全部破坏。
-- ②：这张卡被送去墓地的回合的结束阶段才能发动。从卡组选1只「护宝炮妖」怪兽或「阿不思的落胤」加入手卡或特殊召唤。
function c1906812.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合素材条件：「阿不思的落胤」1只＋满足mfilter（本回合特殊召唤的效果怪兽）的怪兽1只
	aux.AddFusionProcCodeFun(c,68468459,c1906812.mfilter,1,true,true)
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己主要阶段才能发动。自己场上的这张卡的位置向其他的自己的主要怪兽区域移动。那之后，可以把和移动过的这张卡相同纵列的其他的表侧表示卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1906812,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,1906812)
	e1:SetTarget(c1906812.seqtg)
	e1:SetOperation(c1906812.seqop)
	c:RegisterEffect(e1)
	-- 这张卡被送去墓地的回合
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_TO_GRAVE)
	e0:SetOperation(c1906812.regop)
	c:RegisterEffect(e0)
	-- 这个卡名的①②的效果1回合各能使用1次。②：这张卡被送去墓地的回合的结束阶段才能发动。从卡组选1只「护宝炮妖」怪兽或「阿不思的落胤」加入手卡或特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1906812,1))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,1906813)
	e2:SetCondition(c1906812.thcon)
	e2:SetTarget(c1906812.thtg)
	e2:SetOperation(c1906812.thop)
	c:RegisterEffect(e2)
end
-- 「烙印」等融合卡片使用的辅助素材校验函数，检查素材组sg是否分别满足「阿不思的落胤」与mfilter条件
function c1906812.branded_fusion_check(tp,sg,fc)
	-- 调用aux.gffcheck检查2张融合素材是否分别为「阿不思的落胤」和本回合特召的效果怪兽
	return aux.gffcheck(sg,Card.IsFusionCode,68468459,c1906812.mfilter,nil)
end
-- 融合素材过滤函数：筛选位于怪兽区、本回合特殊召唤且融合属性为效果怪兽的卡
function c1906812.mfilter(c)
	return c:IsStatus(STATUS_SPSUMMON_TURN) and c:IsFusionType(TYPE_EFFECT) and c:IsLocation(LOCATION_MZONE)
end
-- 检查①效果发动条件：己方主要怪兽区存在至少1个其他可用的移动空位
function c1906812.seqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动前确认己方主要怪兽区还有未占用的空位可供移动
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)>0 end
end
-- ①效果处理：将此卡移动到己方主要怪兽区的其他空位，若成功移动且同纵列存在其他表侧表示卡，可选择将其全部破坏
function c1906812.seqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡不再与效果关联、不受此效果影响、控制权已转移或己方主要怪兽区已无空位，则中止处理
	if not c:IsRelateToEffect(e) or c:IsImmuneToEffect(e) or not c:IsControler(tp) or Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)<=0 then return end
	-- 向己方发送选择要移动到的怪兽格位置的提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
	-- 让己方在己方主要怪兽区选择1个可用的空格，返回其区域位掩码
	local fd=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
	-- 在界面上高亮提示玩家所选择的移动目标格子
	Duel.Hint(HINT_ZONE,tp,fd)
	local seq=math.log(fd,2)
	local pseq=c:GetSequence()
	-- 将此卡移动到所选序号seq对应的主要怪兽区格子
	Duel.MoveSequence(c,seq)
	if c:GetSequence()==seq then
		local g=c:GetColumnGroup():Filter(Card.IsFaceup,nil)
		-- 若同纵列存在其他表侧表示的卡，询问己方是否将其全部破坏
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(1906812,2)) then  --"是否把同纵列表侧表示的卡全部破坏？"
			-- 插入效果处理间断，使移动位置与破坏同纵列卡片视为不同时处理
			Duel.BreakEffect()
			-- 将与移动后的此卡同纵列的其他表侧表示卡全部以效果破坏
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
-- 记录此卡被送去墓地的状态标记，持续至本回合结束阶段用于判定②效果发动条件
function c1906812.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(1906812,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 检查②效果发动条件：此卡是否在本回合被送去墓地（带有对应的标记效果）
function c1906812.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(1906812)>0
end
-- 过滤卡组中可加入手卡或在有空位时可特殊召唤的「护宝炮妖」怪兽或「阿不思的落胤」
function c1906812.thfilter(c,e,tp)
	if not (c:IsSetCard(0x155) and c:IsType(TYPE_MONSTER) or c:IsCode(68468459)) then return false end
	-- 获取己方怪兽区当前的可用空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 发动前确认己方卡组中是否存在符合条件且可检索或特殊召唤的卡
function c1906812.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方卡组中是否至少有1张可加入手卡或特殊召唤的目标卡
	if chk==0 then return Duel.IsExistingMatchingCard(c1906812.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
end
-- ②效果处理：从己方卡组选1只「护宝炮妖」怪兽或「阿不思的落胤」，根据可行性与玩家选择将其加入手卡或特殊召唤
function c1906812.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向己方发送从卡组选择要操作的卡片的提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 让己方从卡组选择1只符合条件的「护宝炮妖」怪兽或「阿不思的落胤」
	local g=Duel.SelectMatchingCard(tp,c1906812.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 获取当前己方怪兽区可用空位数，用于后续能否特殊召唤的判断
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local tc=g:GetFirst()
	if tc then
		-- 判断选中的卡是否能加入手卡，并在无法特召、场上无空位或玩家选择加入手卡时执行检索分支
		if tc:IsAbleToHand() and (not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or ft<=0 or Duel.SelectOption(tp,1190,1152)==0) then
			-- 将选中的卡以效果加入持有者手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方玩家展示加入手卡的卡片进行确认
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 将选中的怪兽以表侧表示特殊召唤到己方场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
